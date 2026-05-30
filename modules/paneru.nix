{ config, inputs, ... }:
let
  username = config.flake.meta.owner.username;
in {
  flake.modules.darwin.paneru = { pkgs, ... }: {
    home = {
    imports = [
      inputs.paneru.homeModules.paneru
    ];

    services.paneru = {
      enable = true;
      # Paneru configuration
      # See CONFIGURATION.md for a list of all options
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = false;
          auto_center = false;
          preset_column_widths = [0.25 0.33 0.5 0.66 0.75];
          #swipe_gesture_fingers = 3;
          animation_speed = 16;
        };
        padding = {
          top = 4;
          bottom = 4;
          left = 4;
          right = 4;
        };
        decorations.active.border = {
          enabled = true;
          color = "#89b4fa";
          width = 2.0;
          radius = 12.0;
        };
        bindings = {
          window_focus_west = "alt - leftarrow";
          window_focus_east = "alt - rightarrow";
          window_grow = "alt - equal";
          window_shrink = "alt - minus";
          quit = "ctrl + alt - q";

          # Focus north/south (switches display if no window exists)
          window_focus_north = "alt - uparrow";
          window_focus_south = "alt - downarrow";

          # Move windows (swap with neighbour, like niri's move-column)
          window_swap_west = "alt + shift - leftarrow";
          window_swap_east = "alt + shift - rightarrow";
          window_swap_north = "alt + shift - uparrow";   # moves to display above if at edge
          window_swap_south = "alt + shift - downarrow"; # moves to display below if at edge

          # Width / layout (mirrors niri's Mod+W, Mod+Return, Mod+C)
          window_resize = "alt - w";
          window_fullwidth = "alt - return";
          window_center = "alt - c";

          # Floating toggle (niri doesn't have this but useful on macOS)
          window_manage = "alt - space";

          # Multi-monitor
          window_nextdisplay = "alt + shift - m";
        };
        windows.all = {
          title = ".*";
          horizontal_padding = 4;
          vertical_padding = 2;
          #width = 0.4;
        };
        #swipe = {
        #  gesture = {
        #    fingers_count = "3";
        #  };
        #};
      };
    };
};
  };
}
