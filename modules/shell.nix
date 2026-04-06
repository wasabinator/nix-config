{ config, inputs, ... }:
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
  flake.nixosModules.shell = {
    home = homeConfig;
  };

  flake.darwinModules.shell = {
    home = homeConfig;
  };
}
