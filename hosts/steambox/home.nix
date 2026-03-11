{ pkgs, username, ... }:
{
  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnome-extension-manager
    mangohud
    protonup-ng
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "terminate:ctrl_alt_bksp" "caps:shift" ];
    };
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        caffeine.extensionUuid
        dash-to-dock.extensionUuid
      ];
      welcome-dialog-last-shown-version = "9999999";
    };
    "org/gnome/shell/extensions/dash-to-dock".disable-overview-on-startup = true;
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };
}

