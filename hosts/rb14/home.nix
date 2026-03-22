{ pkgs, lib, self, ... }:
let
  videoTypes = map (t: "video/${t}") [
    "3gp" "3gpp" "3gpp2" "dv" "divx" "fli" "flv" "mp2t" "mp4" "mp4v-es"
    "mpeg" "mpeg-system" "msvideo" "ogg" "quicktime" "vivo" "vnd.divx"
    "vnd.mpegurl" "vnd.rn-realvideo" "vnd.vivo" "webm" "x-anim" "x-avi"
    "x-flc" "x-fli" "x-flic" "x-flv" "x-m4v" "x-matroska" "x-mjpeg"
    "x-mpeg" "x-mpeg2" "x-ms-asf" "x-ms-asf-plugin" "x-ms-asx" "x-msvideo"
    "x-ms-wm" "x-ms-wmv" "x-ms-wvx" "x-nsv" "x-ogm+ogg" "x-theora"
    "x-theora+ogg"
  ];
in
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
    celluloid
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
    mimeApps = {
      enable = true;
      defaultApplications = builtins.listToAttrs (
        map (mime: { name = mime; value = "io.github.celluloid_player.Celluloid.desktop"; }) videoTypes
      );
    };
  };
}

