{ config, ... }:
let
  username = config.flake.meta.owner.username;
in {
  flake.modules.nixos.niri = { pkgs, ... }: {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
      waybar
      fuzzel
      hypridle
      pavucontrol
      swaylock
      wlogout
    ];

    home = { pkgs, ... }: {
      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };

      xdg = {
        enable = true;
        configFile."niri/config.kdl".text = ''
          prefer-no-csd true

          output "eDP-1" {
            scale 1.5
          }

          input {
            keyboard {
              xkb {
                layout "us"
              }
            }
            touchpad {
              natural-scroll
              tap
            }
          }

          spawn-at-startup "hypridle"
          spawn-at-startup "waybar"
          spawn-at-startup "ghostty"

          hotkey-overlay {
            skip-at-startup
            hide-not-bound
          }

          binds {
            Mod+Slash { show-hotkey-overlay; }

            Mod+P { spawn "wlogout" "-b" "2"; }
            Mod+T { spawn "ghostty"; }
            Mod+B { spawn "firefox"; }
            Mod+R { spawn "fuzzel"; }
            Mod+F { spawn "nautilus"; }

            Mod+Q { close-window; }
            Mod+Space { toggle-overview; }

            // Workspace navigation
            Mod+Up   { focus-workspace-up; }
            Mod+Down { focus-workspace-down; }

            // Move window to another workspace
            Mod+Shift+Up   { move-window-to-workspace-up; }
            Mod+Shift+Down { move-window-to-workspace-down; }

            // Column navigation (horizontal)
            Mod+Left  { focus-column-left; }
            Mod+Right { focus-column-right; }

            // Move column horizontally
            Mod+Shift+Left  { move-column-left; }
            Mod+Shift+Right { move-column-right; }

            // Width adjustments
            Mod+W { switch-preset-column-width; }
            Mod+Minus { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }

            Mod+C { center-column; }
            Mod+Return { fullscreen-window; }

            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
            XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
            XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

            // Example media keys mapping using playerctl.
            // This will work with any MPRIS-enabled media player.
            XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
            XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
            XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
            XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }

            // Example brightness key mappings for brightnessctl.
            // You can use regular spawn with multiple arguments too (to avoid going through "sh"),
            // but you need to manually put each argument in separate "" quotes.
            XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
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
            match app-id="firefox" title="Private Browsing"
            block-out-from "screen-capture"
          }

          window-rule {
            match app-id="org.pulseaudio.pavucontrol"
            open-floating true
          }
        '';

        configFile."hypr/hypridle.conf".text = ''
          general {
            lock_cmd = swaylock -f
            before_sleep_cmd = swaylock -f
            after_sleep_cmd = swaylock -f
            ignore_dbus_inhibit = false
          }

          listener {
            timeout = 300
            on-timeout = swaylock -f
          }
        '';

        configFile."wlogout/layout".text = ''
          {
            "label" : "lock",
            "action" : "loginctl lock-session",
            "text" : "Lock",
            "keybind" : "l"
          }
          {
            "label" : "logout",
            "action" : "loginctl terminate-user $USER",
            "text" : "Logout",
            "keybind" : "e"
          }
          {
            "label" : "shutdown",
            "action" : "systemctl poweroff",
            "text" : "Shutdown",
            "keybind" : "s"
          }
          {
            "label" : "reboot",
            "action" : "systemctl reboot",
            "text" : "Reboot",
            "keybind" : "r"
          }
        '';
      };

      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            modules-center = [ "clock" ];
            modules-right = [ "tray" "network" "pulseaudio" "power-profiles-daemon" "battery" "custom/power" ];
            clock = {
              format = "{:%I:%M%p | %A, %d %B %Y}";
            };
            network = {
              format-wifi = "󰤨 {essid}";
              format-ethernet = "󰈀";
              format-disconnected = "󰤭";
              tooltips = true;
            };
            "power-profiles-daemon" = {
              format = "{icon}";
              format-icons = {
                performance = "󰠠";
                balanced = "󰗑";
                "power-saver" = "󰌪";
              };
              tooltip-format = "{profile}";
              on-click = "powerprofilesctl cycle";
            };
            pulseaudio = {
              format = "{icon}";
              format-muted = "󰝟";
              format-icons = {
                default = [ "󰕿" "󰖀" "󰕾" ];
              };
              on-click = "pavucontrol";
            };
            battery = {
              format = "{icon} {capacity}% -{power:02.0f}W";
              format-charging = "{icon} {capacity}% +{power:02.0f}W";
              format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
              states = {
                warning = 30;
                critical = 15;
              };
            };
            "custom/power" = {
              format = "⏻";
              on-click = "wlogout -b 2";
              tooltip = false;
            };
            tray = {
              spacing = 10;
            };
          };
        };
        style = ''
          * {
            font-family: "JetBrains Mono Nerd Font";
            font-size: 13px;
          }
          window#waybar {
            background: #1e1e2e;
            color: #cdd6f4;
          }
          #battery {
            color: #a6e3a1;
          }
          #battery.warning {
            color: #f9e2af;
          }
          #battery.critical {
            color: #f38ba8;
          }

          #tray,
          #battery,
          #network, 
          #pulseaudio,
          #power-profiles-daemon,
          #custom-power {
            margin-right: 10px;
          }
        '';
      };
    };
  };
}
