{ nix-darwin, nixpkgs, home-manager, nix-homebrew, inputs, self }:
{ hostname, system ? "aarch64-darwin" }:

nix-darwin.lib.darwinSystem {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules = [
    ../hosts/mac/configuration.nix { networking.hostName = hostname; }
    home-manager.darwinModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.amiceli.imports = [
        ../hosts/common/home.nix
        ../hosts/mac/common/home.nix
      ];
      home-manager.backupFileExtension = "home-manager-backup";
    }
    nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = "amiceli";
      };
    }
  ];
  specialArgs = {
    inherit self inputs nix-darwin;
  };
}
