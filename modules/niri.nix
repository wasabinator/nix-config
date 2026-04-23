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
      pavucontrol
    ];

    home = { pkgs, ... }: {
      xdg = {
        enable = true;
        configFile."niri/config.kdl".text = ''
          prefer-no-csd true

          output "eDP-1" {
            scale 1.3
          }

          input {
            keyboard {
              xkb {
                layout "us"
                //variant "intl"
              }
            }
            touchpad {
              natural-scroll
              tap
            }
          }

          spawn-at-startup "waybar"
          spawn-at-startup "ghostty"

          hotkey-overlay {
            skip-at-startup
            hide-not-bound
          }

          binds {
            Mod+Slash { show-hotkey-overlay; }

            Mod+P { spawn "niripwmenu"; }
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
            modules-right = [ "tray" "network" "pulseaudio" "power-profiles-daemon" "battery" ];
            clock = {
              format = "{:%H:%M}";
              format-alt = "{:%Y-%m-%d}";
              tooltip-format = "{:%Y-%m-%d | %H:%M}";
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
              format = "{icon} ";
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

          #battery,
          #network, 
          #pulseaudio
          #power-profiles-daemon {
            margin: 0 10px;
          }
        '';
      };
    };
  };
}
