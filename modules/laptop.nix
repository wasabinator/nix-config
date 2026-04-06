{ config, inputs, ... }:
{
  flake.nixosModules.laptop = { pkgs, ... }: {
    home = {
      home.packages = with pkgs; [
        gnomeExtensions.battery-usage-wattmeter
      ];
      dconf.settings = {
        "org/gnome/desktop/interface".show-battery-percentage = true;
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        };
        "org/gnome/settings-daemon/plugins/power".ambient-enabled = false;
        "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
          battery-usage-wattmeter.extensionUuid
        ];
      };
    };
  };
}
