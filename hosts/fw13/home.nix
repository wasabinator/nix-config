{ config, pkgs, ... }:

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
    synology-drive-client
    steam-run
    vlc
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [
      pkgs.fcitx5-mozc
    ];
  };

  xdg = {
    enable = true;

    # App specific settings 
    configFile."Signal/ephemeral.json".source = ./settings/signal-desktop/ephemeral.json;

    # Autostart apps
    configFile."autostart/signal-desktop.desktop".source = ./settings/signal-desktop/signal-desktop.desktop;
    configFile."autostart/synology-drive.desktop".source = ./settings/synology-drive/synology-drive.desktop;
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
        
        fastfetch
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    librewolf = {
      enable = true;
      policies = {
        DisableTelemetry = true;
        Preferences = {
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
        };
        ExtensionSettings = {
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4321653/privacy_badger17-latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          "vpn@proton.ch" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-vpn-firefox-extension/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
        };
      };
    };
  };
  dconf.settings = {
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
      "librewolf.desktop"
      "org.gnome.Nautilus.desktop"
      "org.gnome.Console.desktop"
      "org.gnome.Terminal.desktop"
      "tv.plex.PlexDesktop.desktop"
      "com.plexamp.Plexamp.desktop"
      "org.gnome.Settings.desktop"
    ];
    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = false;
    "org/gtk/settings/file-chooser".clock-format = "12h";
  };

  xdg.configFile = {
    "gtk-3.0/bookmarks".text = ''
      file:///home/amiceli/repo
      file:///home/amiceli/Documents
      file:///home/amiceli/Downloads
      smb://mitsukoshi.local
    '';
  };
}
