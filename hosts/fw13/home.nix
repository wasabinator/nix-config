{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    android-studio
    bambu-studio
    plex-desktop
    plexamp
    protonvpn-gui
    sqlitebrowser
    signal-desktop
    steam-run
    synology-drive-client
    telegram-desktop
    vlc
  ];

  services.flatpak.packages = [
    "com.bambulab.BambuStudio"
    "com.github.tchx84.Flatseal"
    "com.system76.Popsicle"
    "io.github.ciromattia.kcc"
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

