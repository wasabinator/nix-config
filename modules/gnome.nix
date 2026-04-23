{ config, ... }:
let
  username = config.flake.meta.owner.username;
in {
  flake.modules.nixos.gnome = { pkgs, ... }: {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.xserver.enable = true;

    home = { lib, ... }: {
      home.packages = with pkgs; [
        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.tiling-shell
        gnome-tweaks
      ];

      dconf.settings = {
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "com.mitchellh.ghostty.desktop"
            "signal.desktop"
            "plex-desktop.desktop"
            "plexamp.desktop"
            "org.gnome.Settings.desktop"
          ];
        };
        "org/gnome/desktop/input-sources" = {
          sources = with lib.hm.gvariant; [ (mkTuple [ "xkb" "au" ]) (mkTuple [ "ibus" "mozc-on" ]) ];
          xkb-options = "['terminate:ctrl_alt_bksp']";
        };
        "org/gnome/desktop/interface" = {
          clock-format = "12h";
          clock-show-weekday = true;
          text-scaling-factor = 1;
        };
        "org/gnome/desktop/peripherals/mouse".natural-scroll = true;
        "org/gnome/desktop/privacy" = {
          recent-files-max-age = -1;
          remember-recent-files = false;
        };
        "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
        "org/gnome/mutter".dynamic-workspaces = true;
        "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
          appindicator.extensionUuid
          dash-to-dock.extensionUuid
          tiling-shell.extensionUuid
        ];
        "org/gtk/gtk4/settings/file-chooser".sort-directories-first = false;
        "org/gtk/settings/file-chooser".clock-format = "12h";
      };

      xdg = {
        enable = true;
        configFile."Signal/ephemeral.json" = {
          force = true;
          source = ./settings/signal-desktop/ephemeral.json;
        };
        configFile."autostart/signal-desktop.desktop" = {
          force = true;
          source = ./settings/signal-desktop/signal-desktop.desktop;
        };
        configFile."autostart/synology-drive.desktop" = {
          force = true;
          source = ./settings/synology-drive/synology-drive.desktop;
        };
        configFile."gtk-3.0/bookmarks" = {
          force = true;
          text = ''
            file:///home/${username}/repo
            file:///home/${username}/Documents
            file:///home/${username}/Downloads
            smb://mitsukoshi.local
          '';
        };
      };
    };
  };
}
