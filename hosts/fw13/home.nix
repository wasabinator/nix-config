{ config, pkgs, ... }:

{
#  nixpkgs = {
#    config.allowUnfree = true;
#    overlays = [
#      # Workaround for Fedora
#      (final: prev: { openssh = prev.openssh_gssapi; } )
#    ];
#  };

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    #cryptomator
    fastfetch
    gnomeExtensions.appindicator
    gnomeExtensions.battery-usage-wattmeter
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tiling-shell
    gnome-tweaks
    rustup
    rust-script
    signal-desktop
    sqlitebrowser    
    synology-drive-client
    steam-run
    telegram-desktop
    vlc
  ];

  home.file = {
    ".config/autostart/org.cryptomator.Cryptomator.desktop".source = ./autostart/org.cryptomator.Cryptomator.desktop;
    ".config/autostart/signal-desktop.desktop".source = ./autostart/signal-desktop.desktop;
    ".config/autostart/synology-drive.desktop".source = ./autostart/synology-drive.desktop;
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

    git = {
      enable = true;
      userName = "Tony Miceli";
      userEmail = "6946957+wasabinator@users.noreply.github.com";
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
      "firefox.desktop"
      "org.gnome.Nautilus.desktop"
      "org.gnome.Terminal.desktop"
      "code.desktop"
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
