{ config, ... }:
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
in {
  flake.modules.nixos.multimedia = { pkgs, ... }: {
    home = {
      home.packages = with pkgs; [
        celluloid
        gthumb
        plex-desktop
        plexamp
      ];
      xdg = {
        enable = true;
        mimeApps = {
          enable = true;
          defaultApplications = builtins.listToAttrs (
            map (mime: { name = mime; value = "org.gnome.gThumb.desktop"; }) imageTypes
            ++
            map (mime: { name = mime; value = "io.github.celluloid_player.Celluloid.desktop"; }) videoTypes
          );
        };
      };
    };
  };
  flake.modules.darwin.multimedia = { ... }: {
    homebrew = {
      casks = [
        "flowvision"
        "iina"
        "plex"
        "plexamp"
      ];
    };
  };
}
