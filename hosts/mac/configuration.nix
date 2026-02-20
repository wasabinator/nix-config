{ nix-darwin, pkgs, ... }: {
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.enable = false; #allow nix-darwin to work with determinate nix

  system.configurationRevision = nix-darwin.rev or nix-darwin.dirtyRev or null;

  # Used for backwards compatibility. please read the changelog before changing: `darwin-rebuild changelog`.
  system.stateVersion = 5;

  system.defaults.CustomUserPreferences = {
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.spotlight" = {
      DisableSpotlightIndexingOnExternalVolumes = true;
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Declare the user that will be running `nix-darwin`.
  users.users.amiceli = {
    name = "amiceli";
    home = "/Users/amiceli";
  };

  system.primaryUser = "amiceli";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    casks = [
      "bambu-studio"
      "firefox"
      "flowvision"
      "ghostty"
      "iina"
      "kindle-comic-converter"
      "maczip"
      "plex"
      "plexamp"
      "signal"
    ];
  };

  # Nerdfonts
  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    p7zip 
  ];
}

