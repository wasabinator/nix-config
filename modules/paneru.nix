{ config, inputs, ... }:
let
  username = config.flake.meta.owner.username;
in {
  flake.modules.darwin.paneru = { pkgs, ... }: {
    imports = [
      inputs.paneru.darwinModules.paneru
    ];

    services.paneru = {
      enable = true;
      # Paneru configuration
      # See CONFIGURATION.md for a list of all options
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
          auto_center = true;
          preset_column_widths = [0.25 0.33 0.5 0.66 0.75];
          swipe_gesture_fingers = 3;
        };
        bindings = {
          window_focus_west = "cmd - h";
          window_focus_east = "cmd - l";
          window_resize = "alt - r";
          window_center = "alt - c";
          quit = "ctrl + alt - q";
        };
        #swipe = {
        #  gesture = {
        #    fingers_count = "3";
        #  };
        #};
      };
    };
  };
}
