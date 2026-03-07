{ pkgs, username, ... }:
{
  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnome-extension-manager
    mangohud
    protonup-ng
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      caffeine.extensionUuid
    ];
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };
}

