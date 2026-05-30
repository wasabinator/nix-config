{ config, lib, ... }:
let
  homeConfig = { pkgs, ... }: {
    home.packages = with pkgs; [
      fastfetch
      (nnn.override { withNerdIcons = true; })
    ];

    home.sessionVariables = {
      EDITOR = "nano";
    };

    programs.starship = {
      enable = true;
      settings = {
        battery = {
          format = "[$symbol$percentage]($style) ";
          disabled = false;
          display = [
            {
              style = "red bold";
              threshold = 30;
            }
          ];
        };
      };
    };
  };
in {
  flake.modules.nixos.shell = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      p7zip
    ];

    home = lib.recursiveUpdate (homeConfig pkgs) {
      home.sessionVariables = {
        PATH = "$PATH:/var/lib/flatpak/exports/bin";
        LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
        #SIMD_BRIDGE_EXE = "/run/current-system/sw/bin/acbridge.exe";
        #SIMD_WRAP_EXE = "/run/current-system/sw/bin/steam-run";
      };

      programs.bash = {
        enable = true;
        initExtra = ''
          if [ -f /etc/bashrc ]; then
            . /etc/bashrc
          fi
          export EDITOR="nano"
          eval "$(starship init bash)"
          fastfetch
        '';
      };

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_color_valid_path
          eval (starship init fish)
          fastfetch
        '';
      };

      programs.ghostty = {
        enable = true;
        enableFishIntegration = true;
        settings = {          
          command = "${pkgs.fish}/bin/fish";

          font-family = "Jetbrains Mono";
          font-size = 12;
          keybind = [
            "ctrl+h=goto_split:left"
            "ctrl+l=goto_split:right"
          ];
          window-height = 45;
          window-width = 160;
        };
      };
    };
  };

  flake.modules.darwin.shell = { pkgs, ... }: {
    homebrew.casks = [
      "ghostty"
    ];
    home = lib.recursiveUpdate (homeConfig pkgs) {
      programs = with pkgs; {
        dircolors = {
          enable = true;
          enableZshIntegration = true;
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
        };
        fish = {
          enable = true;
          interactiveShellInit = ''
            set fish_color_valid_path
            eval (starship init fish)
            fastfetch
          '';
        };
        ghostty = {
          enable = true;
          package = null; # On darwin we need to use homebrew
          enableFishIntegration = true;
          settings = {          
            command = "${pkgs.zsh}/bin/zsh -l -c 'exec ${pkgs.fish}/bin/fish'";
            font-size = 14;
          };
        };
        zsh = {
          autocd = true;
          enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
            ];
          };
          initContent = ''
            if [[ -z "$ZSH_EXECUTION_STRING" || "$ZSH_EXECUTION_STRING" != *fish* ]]; then
              fastfetch
            fi
          '';
        };
      };
    };
  };
}
