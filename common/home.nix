{ config, lib, pkgs, ... }:

{
  home.stateVersion = "24.11";

  nixpkgs = {
    config.allowUnfree = true;
  };

  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = with pkgs; [
    fastfetch
    jetbrains.pycharm-community
    jetbrains.rust-rover
    rustup
    rust-script
    signal-desktop
    telegram-desktop
  ];

  programs = with pkgs; {
    home-manager.enable = true;

    git = {
      enable = true;
      userEmail = "6946957+wasabinator@users.noreply.github.com";
      userName = "Tony Miceli";
      ignores = [
        ".DS_Store"
        ".direnv"
      ];
    };
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Force config files to go in ~/.config
  xdg.enable = true;
}
