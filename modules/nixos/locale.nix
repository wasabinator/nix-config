{ pkgs, ... }:
{
  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    jetbrains-mono
  ];

  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };
  i18n.supportedLocales = [ "en_AU.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];

  time.timeZone = "Australia/Melbourne";

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
