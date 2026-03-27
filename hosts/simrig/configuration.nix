{ config, pkgs, pkgs-old, lib, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================
  # Boot
  # ============================================================

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Zen kernel — lower latency for sim racing, better responsiveness
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Onboard audio
  boot.kernelModules = [ "snd_hda_codec_realtek" ];

  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=lz4"
    "zswap.max_pool_percent=20"
  ];

  # ============================================================
  # Networking
  # ============================================================

  networking = {
    hostName = "simrig";
    networkmanager.enable = true;

    firewall = {
      enable = true;
      # All telemetry is loopback (game + monocoque on same host) so no UDP
      # ports need to be opened. Uncomment only if you add a separate telemetry
      # display machine to your setup in future.
      # allowedUDPPorts = [ 9000 20777 25565 ];
    };
  };

  # ============================================================
  # Locale / Time
  # ============================================================

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  # ============================================================
  # GPU — NVIDIA RTX 5070 Ti (Blackwell)
  # ============================================================

  # Blackwell requires open kernel modules; proprietary kernel support dropped
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false; # Desktop, no battery management needed
    nvidiaSettings = true;

    # Use the beta/latest package from your unstable input.
    # TODO: switch to stable once 5070 Ti support lands there.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam / 32-bit Proton titles
  };

  # ============================================================
  # ollama cuda
  # ============================================================
  services.ollama = { enable = true; acceleration="cuda"; };

  # ============================================================
  # Hyprland
  # ============================================================

  programs.hyprland = {
    enable = true;
    # Use the hyprland input from your flake for latest builds:
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ============================================================
  # Display Manager
  # ============================================================

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ============================================================
  # Audio — PipeWire
  # ============================================================

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # JACK enabled for low-latency haptic audio path
    jack.enable = true;
  };

  # ============================================================
  # Steam & Gaming
  # ============================================================

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        # 64-bit
        freetype
        fontconfig
        
        # 32-bit (critical for Wine)
        pkgsi686Linux.freetype
        pkgsi686Linux.fontconfig
      ];
    };
  };

  programs.gamemode.enable = true;

  system.activationScripts.protonGESymlink = {
    text = ''
      mkdir -p /home/amiceli/.steam/root/compatibilitytools.d
      ln -sfn ${pkgs.proton-ge-bin.steamcompattool} \
        /home/amiceli/.steam/root/compatibilitytools.d/GE-Proton10-30
    '';
  };

  programs.firefox.enable = true;

  # ============================================================
  # Packages
  # ============================================================

  environment.systemPackages = with pkgs; [
    # ---- Sim racing telemetry / device stack ----
    # simapi provides simd — the shared memory daemon that creates zeroed stubs
    # of all supported sim memory files and detects when a sim starts.
    # monocoque reads from simd and drives all physical devices.
    # simshmbridge provides .exe bridge files for titles that need explicit
    # shared memory bridging (AC, AC EVO) in their Proton prefix.
    pkgs.simapi       # simd daemon + shared library (local derivation)
    pkgs.monocoque    # device manager (local derivation)
    pkgs.simshmbridge # Proton shared memory bridge (local derivation)

    # Moza FFB tuning — native Linux alternative to Pit House for day-to-day use.
    # Covers FFB profiles and axis configuration on the R5 base.
    # Note: firmware updates still require Pit House (Windows / separate Bottle).
    oversteer

    # Arduino toolchain — for flashing monocoque's bundled sketches:
    #   simwind (wind simulation motor), shiftlights, simhaptic (haptic motor)
    # Sketches are installed to /run/current-system/sw/share/monocoque/arduino/
    arduino-cli

    # Wayland / Hyprland utilities
    waybar
    wofi
    dunst
    hyprpaper
    wl-clipboard
    xdg-utils
    networkmanagerapplet

    # Audio control — manage main audio vs USB haptic audio card
    pavucontrol
    ffmpeg  # monocoque uses ffmpeg-style sine wave generation for haptic testing

    # Hardware / USB diagnostics
    usbutils        # lsusb — verify Moza + Arduino enumeration
    pciutils
    linuxConsoleTools # jstest — verify joystick axes / FFB

    # General utilities
    htop
    git
    wget
    curl

    # Proton
    pkgs-old.protontricks
  ];

  # ============================================================
  # Local package overlays
  # ============================================================
  # Wire in the local derivations from pkgs/ in this host's directory.
  # These build simapi, monocoque, and simshmbridge from source.

  nixpkgs.overlays = [
    (final: prev: {
      argtable2    = final.callPackage ./pkgs/argtable2 {};
      simapi      = final.callPackage ./pkgs/simapi {};
      monocoque   = final.callPackage ./pkgs/monocoque { inherit (final) simapi argtable2; };
      simshmbridge = final.callPackage ./pkgs/simshmbridge {};
    })
  ];

  # ============================================================
  # simd — shared memory daemon (systemd system service)
  # ============================================================
  # simd must start before monocoque and before any games launch.
  # It creates zeroed shared memory stubs for all supported sims so that
  # monocoque can open them immediately without waiting for a game to start.
  # It also detects when a supported sim process starts/stops.

  systemd.services.simd = {
    description = "simapi shared memory daemon";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "network.target" ];
    serviceConfig = {
      ExecStart     = "${pkgs.simapi}/bin/simd";
      Restart       = "on-failure";
      RestartSec    = "3s";
      # Run as the sim racing user so shared memory files have correct ownership
      User  = username;
      Group = "users";
    };
  };

  # ============================================================
  # USB Device Access & udev Rules
  # ============================================================

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"   # Arduino serial (/dev/ttyUSB*, /dev/ttyACM*)
      "audio"     # USB audio card for haptic motor
      "input"     # Moza devices + general input
      "uinput"    # Virtual input device creation
      "video"
    ];
  };

  services.udev.extraRules = ''
    # ---- Arduino / SimHub serial devices ----
    # CH340 USB-serial (common on Arduino clones)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", MODE="0666", GROUP="dialout"
    # ATmega USB (genuine Arduino Uno / Mega)
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", MODE="0666", GROUP="dialout"
    # Generic USB serial catch-all
    SUBSYSTEM=="usb", MODE="0664", GROUP="dialout"

    # ---- Moza Racing devices (vendor ID: 346e) ----
    # Covers: R5 wheelbase, KS wheel, SRP Lite pedals,
    #         HGP shifter, GSP shifter, HBP handbrake
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="346e", MODE="0664", GROUP="input"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="346e", MODE="0664", GROUP="input"
    SUBSYSTEM=="input",  ATTRS{idVendor}=="346e", MODE="0664", GROUP="input"

    # Arduino Uno (wind motor) — stable symlink at /dev/arduino-wind
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", \
    ATTRS{serial}=="9503331303135191D0E0", SYMLINK+="arduino-wind"
  '';

  # ============================================================
  # Security / Polkit
  # ============================================================

  security.polkit.enable = true;
  security.pam.services.hyprlock = {};

  # ============================================================
  # Fonts
  # ============================================================

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  };

  # ============================================================
  # Nix settings
  # ============================================================

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "25.11";
}
