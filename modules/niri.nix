{ ... }:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri.enable = true;

      environment.systemPackages = with pkgs; [
        noctalia
        xwayland-satellite
      ];

      home =
        { pkgs, ... }:
        {
          services.gnome-keyring = {
            enable = true;
            components = [ "secrets" ];
          };

          services.mako = {
            enable = true;
            extraConfig = ''
              default-timeout=5000

              [app-name=ibus]
              invisible=1
            '';
          };

          xdg = {
            enable = true;

            configFile."niri/config.kdl".text = ''
              prefer-no-csd true

              output "eDP-1" {
                mode "2560x1440@60.002"
                position x=0 y=0
                scale 1.5
              }

              output "DP-1" {
                mode "3440x1440@119.881"
                position x=1707 y=-480
                variable-refresh-rate
              }

              input {
                keyboard {
                  xkb {
                    layout "us"
                  }
                }
                focus-follows-mouse
                touchpad {
                  natural-scroll
                  tap
                }
              }

              spawn-at-startup "gnome-keyring-daemon" "--start" "--components=secrets"
              spawn-at-startup "noctalia"

              spawn-at-startup "firefox"
              spawn-at-startup "flatpak" "run" "org.signal.Signal"

              hotkey-overlay {
                skip-at-startup
                hide-not-bound
              }

              binds {
                Mod+Slash { show-hotkey-overlay; }

                Mod+A { spawn "plexamp"; }
                Mod+T { spawn "ghostty"; }
                Mod+B { spawn "firefox"; }
                Mod+F { spawn "nautilus"; }
                Mod+Space { spawn "fcitx5-remote" "-t"; }

                Mod+Q { close-window; }
                Mod+O { toggle-overview; }

                // Workspace navigation
                Mod+Up   { focus-workspace-up; }
                Mod+Down { focus-workspace-down; }

                // Move window to another workspace
                Mod+Shift+Up   { move-window-to-workspace-up; }
                Mod+Shift+Down { move-window-to-workspace-down; }

                // Column navigation (horizontal)
                Mod+Left  { focus-column-or-monitor-left; }
                Mod+Right { focus-column-or-monitor-right; }

                // Move column horizontally
                Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
                Mod+Shift+Right { move-column-right-or-to-monitor-right; }

                // Move between monitors
                Mod+Shift+Alt+Left  { move-window-to-monitor-left; }
                Mod+Shift+Alt+Right { move-window-to-monitor-right; }
                Mod+Shift+Alt+Up    { move-window-to-monitor-up; }
                Mod+Shift+Alt+Down  { move-window-to-monitor-down; }

                // Width adjustments
                Mod+Minus { set-column-width "-10%"; }
                Mod+Equal { set-column-width "+10%"; }

                Mod+Return { fullscreen-window; }

                Print { screenshot; }
                Ctrl+Print { screenshot-screen; }
                Alt+Print { screenshot-window; }

                // Noctalia
                Mod+Shift+Return      hotkey-overlay-title="Open Wallpaper Selector: noctalia wallpaper toggle" { spawn-sh "noctalia msg panel-toggle wallpaper"; }
                Mod+C                 hotkey-overlay-title="Open Control Center: noctalia controlCenter" { spawn-sh "noctalia msg panel-toggle control-center"; }
                Mod+S                 hotkey-overlay-title="Open Settings: noctalia settings" { spawn-sh "noctalia msg settings-toggle"; }
                Mod+R                 hotkey-overlay-title="Open App Launcher: noctalia launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }
                Mod+L                 hotkey-overlay-title="Lock Screen: noctalia lock" { spawn-sh "noctalia msg session lock"; }
                Mod+Shift+Q           hotkey-overlay-title="Session Menu: noctalia sessionMenu" { spawn-sh "noctalia msg panel-toggle session"; }
                XF86AudioRaiseVolume  allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }
                XF86AudioLowerVolume  allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }
                XF86AudioMute         allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }
                XF86AudioMicMute      allow-when-locked=true { spawn-sh "noctalia msg mic-mute"; }
                XF86AudioNext         allow-when-locked=true { spawn-sh "noctalia msg media next"; }
                XF86AudioPrev         allow-when-locked=true { spawn-sh "noctalia msg media previous"; }
                XF86AudioPlay         allow-when-locked=true { spawn-sh "noctalia msg media toggle"; }
                XF86AudioPause        allow-when-locked=true { spawn-sh "noctalia msg media toggle"; }
                XF86MonBrightnessUp   allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }
                XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }
              }

              layout {
                gaps 8
                focus-ring {
                  width 2
                }

                preset-column-widths {
                  proportion 0.33333
                  proportion 0.5
                  proportion 0.66667
                  proportion 1.0
                }
              }

              window-rule {
                geometry-corner-radius 4
                clip-to-geometry true
              }

              window-rule {
                match app-id="com.mitchellh.ghostty"
                default-column-width { proportion 0.6; }
              }

              window-rule {
                match app-id="firefox"
                default-column-width { proportion 0.8; }
              }

              window-rule {
                match app-id="firefox" title="^Picture-in-Picture$"
                open-floating true
                default-column-width { fixed 640; }
                default-window-height { fixed 360; }
                default-floating-position x=20 y=20 relative-to="bottom-right"
              }

              window-rule {
                match app-id="firefox" title="Private Browsing"
                block-out-from "screencast"
              }

              window-rule {
                match app-id="org.pulseaudio.pavucontrol"
                open-floating true
                default-floating-position x=20 y=20 relative-to="top-right"
              }

              window-rule {
                match app-id="plexamp"
                open-floating true
                default-column-width { fixed 256; }
                default-window-height { fixed 480; }
                default-floating-position x=20 y=20 relative-to="bottom-right"
              }

            '';

            configFile."noctalia/config.toml".text = ''
              [shell]
              polkit_agent = true

              [bar.default]
              margin_ends = 0
              start  = ["launcher"]
              center = ["clock"]
              end    = ["media", "tray", "notifications", "clipboard", "network", "bluetooth", "volume", "brightness", "battery", "battery_pwr", "control-center", "session"]

              [widget.battery_pwr]
              type = "battery"
              display_mode = "none" # Hides the icon so you don't have two icons side-by-side
              show_label = true
              label_content = "rate"
            '';
          };
        };
    };
}
