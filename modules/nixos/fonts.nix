{ pkgs, ... }:
{
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    jetbrains-mono
  ];
}

