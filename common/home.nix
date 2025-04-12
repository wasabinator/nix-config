{ config, lib, pkgs, ... }:

{
  home.stateVersion = "24.11";

  # Force config files to go in ~/.config
  xdg.enable = true;

  home.packages = with pkgs; [
    fastfetch
    kcc
    rustup
    rust-script
  ];

  programs = with pkgs; {
    home-manager.enable = true;

    ghostty = {
      #nix-darwin target is currently broken, so needs to be enabled for linux only, and we just use this to specify the config but install via brew-nix on darwin
      #enable = true;
      settings = {
        theme = "LiquidCarbonTransparent";
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

    git = {
      enable = true;
      userEmail = "6946957+wasabinator@users.noreply.github.com";
      userName = "Tony Miceli";
      ignores = [
        ".DS_Store"
        ".direnv"
      ];
    };

    starship = {
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

  home.sessionVariables = {
    EDITOR = "nano";
  };
}
