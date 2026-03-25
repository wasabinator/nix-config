{ pkgs, lib, username, self, ... }:
let
  imageTypes = map (t: "image/${t}") [
    "bmp" "jpeg" "gif" "png" "tiff" "x-bmp" "x-ico" "x-png"
    "x-pcx" "x-tga" "xpm" "svg+xml" "webp" "jxl"
  ];
  videoTypes = map (t: "video/${t}") [
    "3gp" "3gpp" "3gpp2" "dv" "divx" "fli" "flv" "mp2t" "mp4" "mp4v-es"
    "mpeg" "mpeg-system" "msvideo" "ogg" "quicktime" "vivo" "vnd.divx"
    "vnd.mpegurl" "vnd.rn-realvideo" "vnd.vivo" "webm" "x-anim" "x-avi"
    "x-flc" "x-fli" "x-flic" "x-flv" "x-m4v" "x-matroska" "x-mjpeg"
    "x-mpeg" "x-mpeg2" "x-ms-asf" "x-ms-asf-plugin" "x-ms-asx" "x-msvideo"
    "x-ms-wm" "x-ms-wmv" "x-ms-wvx" "x-nsv" "x-ogm+ogg" "x-theora"
    "x-theora+ogg"
  ];
  browsableTypes = [
    "text/html" "x-scheme-handler/http" "x-scheme-handler/https"
    "x-scheme-handler/about" "x-scheme-handler/unknown"
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
    gthumb
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
    mimeApps = {
      enable = true;
      defaultApplications = builtins.listToAttrs (
        map (mime: { name = mime; value = "org.gnome.gThumb.desktop"; }) imageTypes
        ++
        map (mime: { name = mime; value = "io.github.celluloid_player.Celluloid.desktop"; }) videoTypes
        ++
        map (mime: { name = mime; value = "firefox.desktop"; }) browsableTypes
      );
    };
  };
}

