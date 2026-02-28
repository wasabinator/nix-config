{ pkgs, lib, self, ... }:
{
  imports = [
    (self + "/modules/nixos/home/programs.nix")
    (self + "/modules/nixos/home/gnome.nix")
    (self + "/modules/nixos/home/laptop.nix")
  ];

  home.packages = with pkgs; [
    android-studio
    bambu-studio
    plex-desktop
    plexamp
    protonvpn-gui
    sqlitebrowser
    (signal-desktop.override {
      commandLineArgs = "--disable-gpu";
    })
    steam-run
    synology-drive-client
    vivaldi
    vlc
  ];

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
        file:///home/amiceli/repo
        file:///home/amiceli/Documents
        file:///home/amiceli/Downloads
        smb://mitsukoshi.local
      '';
    };
  };
}

