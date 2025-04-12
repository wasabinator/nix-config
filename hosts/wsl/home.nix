{ config, pkgs, lib, ... }:

{
  home.username = "amiceli";

  home.packages = with pkgs; [
    starship
    steam-run
  ];

  programs = with pkgs; {
    bash = {
      enable = true;
      sessionVariables = {
      };
      initExtra = ''
        # Source global definitions
        if [ -f /etc/bashrc ]; then
          . /etc/bashrc
        fi

        export EDITOR="nano"
        eval "$(starship init bash)"

        fastfetch
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
