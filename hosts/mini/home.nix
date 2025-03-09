{ config, lib, pkgs, ... }:

{
  home.username = "amiceli";
  home.homeDirectory = "/Users/amiceli";

  home.packages = with pkgs; [
    brewCasks.firefox
    brewCasks.plex
    brewCasks.plexamp
    dockutil
    vlc-bin
  ];

  programs = with pkgs; {
    home-manager.enable = true;

    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      autocd = true;
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };
      initExtra = ''
        fastfetch
      '';
    };
  };

  targets.darwin.defaults = {
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      largesize = 128;
      magnification = true;
      orientation = "bottom";
      show-recents = false;
      tilesize = 36;
    };
    "com.apple.finder" = {
      AppleShowAllFiles = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = false;
      show-recents = false;
      #recent-apps = [ ];
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      "com.apple.mouse" = {
        linear = false;
        scaling = 3.0;
      };
    };
  };

  home.activation.createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.dockutil}/bin/dockutil \
      --remove all \
      --add /Applications/Launchpad.app \
      --add /Applications/Utilities/Terminal.app \
      --add "${pkgs.brewCasks.firefox}/Applications/Firefox.app" \
      --add "${pkgs.signal-desktop}/Applications/Signal.app" \
      --add "${pkgs.telegram-desktop}/Applications/Telegram.app" \
      --add /System/Applications/Calendar.app \
      --add /System/Applications/Notes.app \
      --add "/System/Applications/System Settings.app"
  '';
}
