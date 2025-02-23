{ config, lib, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "amiceli";
  home.homeDirectory = "/Users/amiceli";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  nixpkgs = {
    config.allowUnfree = true;
  };

  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = with pkgs; [
    brewCasks.android-studio
    brewCasks.plex
    brewCasks.plexamp
    dockutil
    fastfetch
    jetbrains.pycharm-community
    jetbrains.rust-rover
    rustup
    rust-script
    signal-desktop
    telegram-desktop
    vlc-bin

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
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

    git = {
      enable = true;
      userEmail = "6946957+wasabinator@users.noreply.github.com";
      userName = "Tony Miceli";
      ignores = [
        ".DS_Store"
        ".direnv"
      ];
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/amiceli/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nano";
  };

  home.activation.createDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.dockutil}/bin/dockutil \
      --remove all \
      --add /Applications/Launchpad.app \
      --add /Applications/Utilities/Terminal.app \
      --add /Applications/Firefox.app \
      --add "${pkgs.signal-desktop}/Applications/Signal.app" \
      --add "${pkgs.telegram-desktop}/Applications/Telegram.app" \
      --add /System/Applications/Calendar.app \
      --add /System/Applications/Notes.app \
      --add "${pkgs.brewCasks.plex}/Applications/Plex.app" \
      --add "${pkgs.brewCasks.plexamp}/Applications/Plexamp.app" \
      --add "/System/Applications/System Settings.app"
  '';

  # Force config files to go in ~/.config rather than /Users/blah/Library/...
  xdg.enable = true;
}
