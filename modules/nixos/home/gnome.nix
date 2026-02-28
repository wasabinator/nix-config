{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tiling-shell
    gnome-tweaks
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = with lib.hm.gvariant; [ (mkTuple [ "xkb" "au" ]) (mkTuple [ "ibus" "mozc-on" ]) ];
      xkb-options = "['terminate:ctrl_alt_bksp']";
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      text-scaling-factor = 1.25;
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
    "org/gnome/shell".favorite-apps = [
      "firefox.desktop"
      "org.gnome.Nautilus.desktop"
      "com.mitchellh.ghostty.desktop"
      "org.gnome.Settings.desktop"
    ];
    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = false;
    "org/gtk/settings/file-chooser".clock-format = "12h";
  };
}

