{ pkgs, ... }:
{
  home.stateVersion = "25.11";
  xdg.enable = true;

  home.packages = with pkgs; [
    fastfetch
    rustup
    rust-script
  ];

  home.sessionVariables = {
    EDITOR = "nano";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = if pkgs.stdenv.isDarwin
          then "/private/var/run/agenix/github"
          else "/run/agenix/github";
      };
    };
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
}
