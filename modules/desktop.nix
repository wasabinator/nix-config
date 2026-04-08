{ config, ... }:
{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      gnome
      internet
      multimedia
    ];

    # Sound
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Printing
    services.printing.enable = true;
    services.printing.browsing = true;
    services.printing.browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All
      BrowseProtocols all
    '';
    services.printing.drivers = with pkgs; [
      cnijfilter2
    ];

    # Japanese IME
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };

    # Needed primarily for AppImages used
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        webkitgtk_4_1
      ];
    };

    # Switch to sudo-rs
    security.sudo-rs.enable = true;

    # Flatpaks
    services.flatpak.packages = [
      "com.bambulab.BambuStudio"
      "com.github.tchx84.Flatseal"
    ];

    # Samba
    services.samba.winbindd.enable = true;
    services.samba.nmbd.enable = true;

    # .local name resolution
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    home = {
      home.packages = with pkgs; [
        protonvpn-gui
        synology-drive-client
      ];

      # Flatpak
      #services.flatpak = {
      #  enable = true;
      #  packages = [
      #    "com.github.tchx84.Flatseal"
      #  ];
      #};
    };
  };

  flake.modules.darwin.desktop = { pkgs, ... }: {
    imports = [
      config.flake.modules.darwin.internet
      config.flake.modules.darwin.multimedia
    ];

    system.defaults.CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
        upgrade = true;
      };
      brews = [
        "sevenzip"
      ];
      casks = [
        "bambu-studio"
        "ghostty"
        "kindle-comic-converter"
        "maczip"
        "synology-drive"
      ];
    };

    # Nerdfonts
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    environment.systemPackages = with pkgs; [
      p7zip
    ];

    home = { lib, ... }: {
      home.packages = with pkgs; [
        dockutil
      ];

      programs = with pkgs; {
        home-manager.enable = true;
      };

      targets.darwin.defaults = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.dock" = {
          largesize = 128;
          magnification = true;
          orientation = "bottom";
          show-recents = false;
          tilesize = 36;
        };
        "com.apple.finder" = {
          AppleShowAllFiles = false;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          ShowPathbar = true;
          ShowStatusBar = false;
          show-recents = false;
        };
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          "com.apple.mouse" = {
            linear = false;
            scaling = 3.0;
          };
        };
      };

      home.activation.createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.dockutil}/bin/dockutil \
          --remove all \
          --add /Applications/Ghostty.app \
          --add /Applications/Firefox.app \
          --add /Applications/Signal.app \
          --add /Applications/Plex.app \
          --add /Applications/Plexamp.app \
          --add "${pkgs.telegram-desktop}/Applications/Telegram.app" \
          --add /System/Applications/Calendar.app \
          --add /System/Applications/Notes.app \
          --add "/System/Applications/System Settings.app"
      '';
    };
  };
}
