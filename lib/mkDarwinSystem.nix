{ nix-darwin, nixpkgs, agenix, home-manager, nix-homebrew, inputs, self }:
{ hostname, username, system ? "aarch64-darwin" }:
nix-darwin.lib.darwinSystem {
  inherit system;
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  specialArgs = { inherit self inputs nix-darwin hostname username; };
  modules = [
    (self + "/modules/darwin/configuration.nix")
    (self + "/users/darwin/${username}.nix")
    { networking.hostName = hostname; }
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs hostname username self; };
      home-manager.users.${username}.imports = [
        (self + "/modules/common/home.nix")
        (self + "/modules/darwin/home.nix")
        { home.stateVersion = "25.11"; }
      ];
      home-manager.backupFileExtension = "home-manager-backup";
    }
    nix-homebrew.darwinModules.nix-homebrew {
      nix-homebrew = {
        enable = true;
        user = username;
      };
    }
    agenix.darwinModules.default {
      age.identityPaths = [ "/Users/${username}/.ssh/agenix" ];
      age.secrets.github = {
        file = self + "/secrets/${hostname}/${username}/github.age";
        mode = "0600";
        owner = username;
      };
    }
  ];
}
