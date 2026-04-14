{ config, ... }:
{
  flake.modules.nixos.development = { pkgs, ... }: {
    services.flatpak.packages = [
      "dev.zed.Zed"
    ];

    environment.systemPackages = with pkgs; [
      ollama-cuda
      opencode
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
