{ config, ... }:
{
  flake.modules.nixos.development = { pkgs, ... }: {
    services.flatpak.packages = [
      "dev.zed.Zed"
    ];

    home = {
      home.packages = with pkgs; [
      ];
    };
  };

  flake.modules.darwin.development = { pkgs, ... }: {
    homebrew = {
      brews = [
      ];
      casks = [
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
