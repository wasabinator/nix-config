{ pkgs, ... }:
{
  home.packages = with pkgs; [
    starship
    fastfetch
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f /etc/bashrc ]; then
        . /etc/bashrc
      fi
      export EDITOR="nano"
      eval "$(starship init bash)"
      fastfetch
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      Preferences = {
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
    };
  };

  programs.ghostty.enable = true;
}

