{ config, lib, ... }:
let
  homeConfig = { pkgs, ... }: {
    home.packages = with pkgs; [
      fastfetch
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
        LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
        SIMD_BRIDGE_EXE = "/run/current-system/sw/bin/acbridge.exe";
        SIMD_WRAP_EXE = "/run/current-system/sw/bin/steam-run";
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

      programs.ghostty = {
        enable = true;
        settings = {
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
            fastfetch
          '';
        };
      };
    };
  };
}
