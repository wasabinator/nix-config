{ config, pkgs, lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    winetricks
  ];

home.file.".local/bin/simd-wine-wrap.sh" = {
  executable = true;
  text = ''
    #!/bin/sh
    export HOME=/home/amiceli
    export XDG_CACHE_HOME=/home/amiceli/.cache
    export WINEDEBUG=-all
    export WINEDLLOVERRIDES="wineusb.sys="
    export WINEPREFIX=/home/amiceli/.local/share/Steam/steamapps/compatdata/244210/pfx
    # Use NixOS-patched wine instead of GE-Proton's wine
    exec ${pkgs.wineWowPackages.staging}/bin/wine "$2" >> /tmp/simd-wrap.log 2>&1
  '';
};

  # ============================================================
  # Hyprland config
  # ============================================================
  # Monitor layout — triple 2560x1440 main displays only.
  # (4th telemetry monitor dropped — no SimHub/dashboard in this config)
  #
  # TODO: verify connector names with `hyprctl monitors` on first boot.
  # Connector names depend on which physical ports you plug into on the 5070 Ti.

  home.file.".local/bin/power-menu.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      choice=$(echo -e 'Shutdown\nReboot\nSuspend\nLogout' | wofi --dmenu --prompt "Power")
      case "$choice" in
        Shutdown) systemctl poweroff ;;
        Reboot)   systemctl reboot ;;
        Suspend)  systemctl suspend ;;
        Logout)   hyprctl dispatch exit ;;
      esac
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = [
        # Triple main screens — left to right
        "DP-4, 2560x1440@165, 0x0, 1"
        "DP-5, 2560x1440@165, 2560x0, 1"
        "DP-6, 2560x1440@165, 5120x0, 1"

        # Top monitor — centred above DP-5
        "HDMI-A-2, 2560x1440@60, 2560x-1440, 1"
      ];

      # Environment variables for NVIDIA + Wayland
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"  # Fixes cursor rendering on NVIDIA
        "NIXOS_OZONE_WL,1"           # Electron / Chromium Wayland hints
      ];

      exec-once = [
        "hyprpaper"   # Wallpaper
        "waybar"      # Status bar
        "dunst"       # Notifications
        "nm-applet --indicator"
      ];

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
      };

      input = {
        kb_layout = "au";
        follow_mouse = 1;
        sensitivity = 0;
      };

      misc = {
        disable_hyprland_logo = true;
      };

      windowrulev2 = [
        # Steam games — fullscreen anchored to centre monitor.
        # AC, ACC and LMU all manage their own triple-screen spanning
        # internally in their graphics settings, so we just anchor the
        # initial window to DP-5 and let the game expand from there.
        "monitor DP-5, class:^(steam_app_.*)$"
        "fullscreen, class:^(steam_app_.*)$"
      ];

      workspace = [
        "1, monitor:DP-5, default:true"   # Main workspace — centre screen
        "2, monitor:DP-4"                 # Left screen
        "3, monitor:DP-6"                 # Right screen
        "10, monitor:HDMI-A-2"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, foot"
        "$mod, D, exec, wofi --show drun"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, E, exec, ~/.local/bin/power-menu.sh"
        "$mod SHIFT, right, movewindow, mon:+1"
        "$mod SHIFT, left, movewindow, mon:-1"
        "$mod, right, movewindow, r"
        "$mod, left, movewindow, l"
        "$mod, down, movewindow, d"
        "$mod, up, movewindow, u"
        # Launch AC
        "$mod, F1, exec, ~/.local/bin/launch-ac.sh"
      ];
    };
  };

  # ============================================================
  # simd — shared memory daemon (systemd system service)
  # ============================================================
  # simd must start before monocoque and before any games launch.
  # It creates zeroed shared memory stubs for all supported sims so that
  # monocoque can open them immediately without waiting for a game to start.
  # It also detects when a supported sim process starts/stops.

  systemd.user.services.simd = {
    Unit = {
      Description = "SimAPI Daemon - Racing Simulator Telemetry Service";
      Documentation = [ "https://github.com/Spacefreak18/simapi" ];
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.simapi}/bin/simd --nodaemon -vv";
      Restart = "on-failure";
      RestartSec = "5";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".config/simd/simd.config" = {
    source = "${pkgs.simapi.src}/simd/conf/simd.config";
  };

  # ============================================================
  # monocoque — user service
  # ============================================================
  # monocoque reads telemetry from simd's shared memory and drives:
  #   - Arduino serial: sim lights, wind motor (simwind sketch)
  #   - USB audio card: haptic motor effects (simhaptic sketch)
  #   - Moza R5: any monocoque-driven FFB extensions beyond Proton's HID path
  #
  # simd (system service, started at boot) must be running first — it creates
  # the shared memory stubs that monocoque opens on startup.
  #
  # monocoque config lives at: ~/.config/monocoque/monocoque.config
  # See /run/current-system/sw/share/monocoque/ for example config files.

  systemd.user.services.monocoque = {
    Unit = {
      Description = "Monocoque sim racing device manager";
      After = [ "simd.service" ];
      Requires = [ "simd.service" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      ExecStart = "${pkgs.util-linux}/bin/script -q -c '${pkgs.monocoque}/bin/monocoque -vv play' /dev/null";
      Restart = "on-failure";
      RestartSec = "3s";
      StandardInput = "null";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.file.".config/monocoque/monocoque.config" = {
    text = ''
      configs = (
        {
          sim = "default";
          devices = (
          {
              device  = "Serial";
              type    = "SimWind";
              config  = "None";
              baud    = 115200;
              devpath = "/dev/arduino-wind";
          },
          {
              device       = "Sound";
              effect       = "Engine";
              devid        = "alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo";
              pan          = 0;
              fps          = 60;
              threshold    = 0.2;
              channels     = 2;
              volume       = 70;
              modulation   = "frequency";
              frequency    = 17;
              frequencyMax = 37;
              noise        = 10;
          });
        }
      );
    '';
  };

  # ============================================================
  # Waybar
  # ============================================================

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        output = [ "HDMI-A-2" ]; # Status bar on centre monitor only
        height = 30;
        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right  = [ "cpu" "memory" "temperature" "pulseaudio" "network" "tray" ];

        "hyprland/workspaces" = { format = "{id}"; };

        clock = { format = "{:%H:%M  %a %d %b}"; };

        cpu = {
          format   = " {usage}%";
          interval = 2;
        };

        memory = {
          format   = " {used:0.1f}G";
          interval = 5;
        };

        temperature = {
          format             = " {temperatureC}°C";
          critical-threshold = 90;
        };

        pulseaudio = {
          format   = " {volume}%";
          on-click = "pavucontrol";
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ipaddr}";
          on-click = "nm-connection-editor";
        };

        tray = {
          spacing = 8;
        };
      };
    };
  };

  # ============================================================
  # Terminal
  # ============================================================

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        term = "xterm-256color";
      };
    };
  };

  # ============================================================
  # Session variables
  # ============================================================

  home.sessionVariables = {
    XDG_SESSION_TYPE    = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    SIMD_BRIDGE_EXE     = "/home/${config.home.username}/.local/share/simshmbridge/acbridge.exe";
    STEAM_COMPAT_CLIENT_INSTALL_PATH = "/home/${config.home.username}/.local/share/Steam";
  };

  # ============================================================
  # XDG dirs
  # ============================================================

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Game specific scripts
home.file.".local/share/simshmbridge/acbridge.exe" = {
  source = "${pkgs.simshmbridge}/share/simshmbridge/acbridge.exe";
};

home.file.".local/bin/launch-ac.sh" = {
  executable = true;
  text = ''
    #!/bin/sh
    AC_APPID=244210
    PROTON_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/$AC_APPID/pfx"

    # Enable AC shared memory if not already set
    PYTHON_INI="$PROTON_PREFIX/drive_c/users/steamuser/Documents/Assetto Corsa/cfg/python.ini"
    if [ -f "$PYTHON_INI" ] && ! grep -q "ACPMF_MEMORY" "$PYTHON_INI"; then
      printf "[ACPMF_MEMORY]\nACTIVE=1\n" >> "$PYTHON_INI"
    fi

    # Launch AC via Steam
    steam steam://rungameid/$AC_APPID &
  '';
};

home.file.".local/bin/old_launch-ac.sh" = {
  executable = true;
  text = ''
    #!/bin/sh

    export PATH="${pkgs.python3}/bin:$PATH"

    AC_APPID=244210

    # Install dotnet48 if not already present in the Proton prefix
    PROTON_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/$AC_APPID/pfx"
    DOTNET_MARKER="$PROTON_PREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319"

    if [ ! -d "$DOTNET_MARKER" ]; then
      echo "Installing dotnet48 via protontricks..."
      protontricks $AC_APPID dotnet48
    fi

    # Enable AC shared memory if not already set
    PYTHON_INI="$HOME/.local/share/Steam/steamapps/compatdata/$AC_APPID/pfx/drive_c/users/steamuser/Documents/Assetto Corsa/cfg/python.ini"

    if [ -f "$PYTHON_INI" ] && ! grep -q "ACPMF_MEMORY" "$PYTHON_INI"; then
      printf "[ACPMF_MEMORY]\nACTIVE=1\n" >> "$PYTHON_INI"
    fi

    # Launch acbridge.exe in the Proton prefix
    export WINEPREFIX="$PROTON_PREFIX"
    WINEFSYNC=1 \
      "/home/${username}/.steam/root/compatibilitytools.d/GE-Proton10-30/proton" run \
      "${pkgs.simshmbridge}/bin/acbridge.exe" &

    # Launch AC via Steam
    steam steam://rungameid/$AC_APPID &

    echo "AC and acbridge.exe launched."
  '';
};

programs.gemini-cli.enable = true;

  # ============================================================
  # One-time setup notes (imperative — run once after first boot)
  # ============================================================
  #
  # --- monocoque config ---
  # Copy example config to ~/.config/monocoque/monocoque.config and edit
  # to match your devices. Example configs are at:
  #   /run/current-system/sw/share/monocoque/
  #
  # Test monocoque can see your devices:
  #   monocoque test -vv
  # Make sure only the devices you have connected are listed in the config
  # before running test, otherwise it will error on missing devices.
  #
  # --- Arduino sketches ---
  # Sketches are installed to:
  #   /run/current-system/sw/share/monocoque/arduino/
  # Flash with arduino-cli. Plug in only the Arduino you're flashing first
  # (monocoque's Makefiles expect /dev/ttyACM0):
  #   cd /run/current-system/sw/share/monocoque/arduino/simwind
  #   make   # flashes simwind sketch (requires motor shield)
  #   cd ../shiftlights
  #   make   # flashes shift light sketch
  #   cd ../simhaptic
  #   make   # flashes haptic motor sketch
  #
  # --- USB audio card (haptic motor) ---
  # Find the PipeWire device name for your USB audio card:
  #   pactl list sinks short
  # Add this name as "devid" in ~/.config/monocoque/monocoque.config
  # Test haptic output with:
  #   ffmpeg -f lavfi -i "sine=f=440" -af "pan=7.1|c1=c0" -f wav pipe:1 | \
  #     paplay --no-remap --no-remix -d <devid> --volume=65536 -n "Monocoque"
  # (WARNING: this sets maximum stream volume — be careful with haptic amp gain)
  #
  # --- simshmbridge — per-game Proton launch commands ---
  # simd (running as system service) creates zeroed shared memory stubs.
  # For AC (AppID 244210) and AC EVO, also add acbridge.exe to the Steam
  # launch command so the bridge maps AC's shared memory into Linux space.
  # Bridge .exe files are at:
  #   /run/current-system/sw/share/simshmbridge/
  # Copy the relevant .exe to a permanent location (e.g. ~/sim/bridges/) first.
  #
  # AC Steam launch command (set in Steam → AC → Properties → Launch Options):
  #   %command% & sleep 5 && WINEFSYNC=1 \
  #   WINEPREFIX=~/.steam/steam/steamapps/compatdata/244210/pfx \
  #   ~/.steam/root/compatibilitytools.d/GE-Proton-latest/files/bin/wine \
  #   ~/sim/bridges/acbridge.exe
  #
  # ACC uses UDP only — no bridge needed, monocoque reads it directly.
  # LMU uses the rF2 plugin + UDP — no bridge needed.
  #
  # --- Moza / oversteer ---
  # Launch oversteer to configure R5 FFB profiles:
  #   oversteer
  # Verify all Moza devices are visible:
  #   lsusb | grep -i 346e
  #   jstest /dev/input/js0   (increment js0, js1... for each device)
  #
  # --- Moza firmware updates ---
  # Still require Pit House (Windows-only). Options:
  #   a) Dual-boot / separate Windows install
  #   b) Create a Bottles prefix with Pit House when a firmware update is needed
  #      (Moza releases firmware infrequently)
}
