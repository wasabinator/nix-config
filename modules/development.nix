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
      home.packages = with pkgs; [
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
    };
  };
}
