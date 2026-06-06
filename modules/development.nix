{ config, ... }:
{
  flake.modules.nixos.development = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      riscv
      vscode
    ];

    environment.systemPackages = with pkgs; [
      gnumake
      #(llama-cpp.override { cudaSupport = true; })
      #opencode
    ];

    home = {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = with pkgs; [
        devenv
      ];
    };
  };

  flake.modules.darwin.development = { pkgs, ... }: {
    imports = with config.flake.modules.darwin; [
      riscv
      vscode
    ];

    homebrew = {
      brews = [
        "opencode"
      ];
      casks = [
        "zed"
      ];
    };

    # Nerdfonts
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    environment.systemPackages = with pkgs; [
    ];

    home = { lib, ... }: {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = with pkgs; [
        devenv
      ];
    };
  };
}
