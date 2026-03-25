{ config, pkgs, lib, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  # ============================================================
  # Hyprland config
  # ============================================================
  # Monitor layout — triple 2560x1440 main displays only.
  # (4th telemetry monitor dropped — no SimHub/dashboard in this config)
  #
  # TODO: verify connector names with `hyprctl monitors` on first boot.
  # Connector names depend on which physical ports you plug into on the 5070 Ti.

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = [
        # Main triple screen — left to right as one 7680x1440 row
        "DP-1, 2560x1440@144, 0x0, 1"
        "DP-2, 2560x1440@144, 2560x0, 1"
        "DP-3, 2560x1440@144, 5120x0, 1"
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

      windowrulev2 = [
        # Steam games — fullscreen anchored to centre monitor.
        # AC, ACC and LMU all manage their own triple-screen spanning
        # internally in their graphics settings, so we just anchor the
        # initial window to DP-2 and let the game expand from there.
        "monitor DP-2, class:^(steam_app_.*)$"
        "fullscreen, class:^(steam_app_.*)$"
      ];

      workspace = [
        "1, monitor:DP-2, default:true"   # Main workspace — centre screen
        "2, monitor:DP-1"                 # Left screen
        "3, monitor:DP-3"                 # Right screen
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
      ];
    };
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
      # Wait for simd (system service) and PipeWire to be ready
      After = [ "pipewire.service" "simd.service" ];
    };
    Service = {
      ExecStart = "${pkgs.monocoque}/bin/monocoque play";
      Restart   = "on-failure";
      RestartSec = "3s";
      # Give simd a moment to populate shared memory on first start
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
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
        output = [ "DP-2" ]; # Status bar on centre monitor only
        height = 30;
        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right  = [ "cpu" "memory" "temperature" "pulseaudio" ];

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
