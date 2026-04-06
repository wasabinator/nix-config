{ config, ... }:
let
  username = config.flake.meta.owner.username;
  internet = config.flake.nixosModules.internet;
  multimedia = config.flake.nixosModules.multimedia;
in {
  flake.nixosModules.desktop = { pkgs, ... }: {
    imports = [ multimedia internet multimedia ];
    home = {
      home.packages = with pkgs; [
        bambu-studio
        plex-desktop
        plexamp
        protonvpn-gui
        synology-drive-client
      ];

      dconf.settings."org/gnome/shell" = {
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
