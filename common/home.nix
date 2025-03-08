{ config, lib, pkgs, ... }:

{
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  # Force config files to go in ~/.config
  xdg.enable = true;

  home.packages = with pkgs; [
    fastfetch
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
}
