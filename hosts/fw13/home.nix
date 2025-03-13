{ config, pkgs, lib, ... }:

{
  home.username = "amiceli";

  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.battery-usage-wattmeter
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tiling-shell
    gnome-tweaks
    plex
    plexamp
    protonvpn-gui
    sqlitebrowser
    starship
    synology-drive-client
    steam-run
    vlc
  ];

  xdg = {
    enable = true;

    # App specific settings 
    configFile."Signal/ephemeral.json" = {
      force = true;
      source = ./settings/signal-desktop/ephemeral.json;
    };

    # Autostart apps
    configFile."autostart/signal-desktop.desktop" = {
      force = true;
      source = ./settings/signal-desktop/signal-desktop.desktop;
    };
    configFile."autostart/synology-drive.desktop" = {
      force = true;
      source = ./settings/synology-drive/synology-drive.desktop;
    };

    # Bookmarks
    configFile."gtk-3.0/bookmarks" = {
      force = true;
      text = ''
        file:///home/amiceli/repo
        file:///home/amiceli/Documents
        file:///home/amiceli/Downloads
        smb://mitsukoshi.local
      '';
    };
  };


  programs = with pkgs; {
    bash = {
      enable = true;
      sessionVariables = {
      };
      initExtra = ''
        # Source global definitions
        if [ -f /etc/bashrc ]; then
          . /etc/bashrc
        fi

        export EDITOR="nano"
        eval "$(starship init bash)"
        
        fastfetch
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    firefox = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        Preferences = {
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = with lib.hm.gvariant; [ (mkTuple [ "xkb" "au" ]) (mkTuple [ "ibus" "mozc-on" ]) ];
      xkb-options = "['terminate:ctrl_alt_bksp']";
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      show-battery-percentage = true;
      text-scaling-factor = 1.25;
    };
    "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/privacy" = {
      recent-files-max-age = -1;
      remember-recent-files = false;
    };
    "org/gnome/desktop/wm/preferences".button-layout = "minimize,maximize,close";
    "org/gnome/mutter".dynamic-workspaces = true;
    "org/gnome/settings-daemon/plugins/power".ambient-enabled = false;
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      appindicator.extensionUuid
      battery-usage-wattmeter.extensionUuid
      dash-to-dock.extensionUuid
      tiling-shell.extensionUuid
    ];
    "org/gnome/shell".favorite-apps = [
      "firefox.desktop"
      "org.gnome.Nautilus.desktop"
      "com.mitchellh.ghostty.desktop"
      "tv.plex.PlexDesktop.desktop"
      "com.plexamp.Plexamp.desktop"
      "org.gnome.Settings.desktop"
    ];
    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = false;
    "org/gtk/settings/file-chooser".clock-format = "12h";
  };
}
