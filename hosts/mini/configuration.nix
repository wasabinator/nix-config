{ nix-darwin, pkgs, ... }: {
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = nix-darwin.rev or nix-darwin.dirtyRev or null;

  # Used for backwards compatibility. please read the changelog before changing: `darwin-rebuild changelog`.
  system.stateVersion = 5;

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
    onActivation.cleanup = "uninstall";
    casks = [
      "firefox"
      "ghostty"
      "kindle-comic-converter"
      "plex"
      "plexamp"
      "signal"
    ];
  };

  # Nerdfonts
  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  environment.systemPackages = [ ];
}

