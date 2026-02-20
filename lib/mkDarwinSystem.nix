{ nix-darwin, nixpkgs, agenix, home-manager, nix-homebrew, inputs, self }:
{ hostname, system ? "aarch64-darwin" }:

nix-darwin.lib.darwinSystem {
  inherit system;
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules = [
    (self + "/hosts/mac/configuration.nix")
    { networking.hostName = hostname; }
    agenix.darwinModules.default
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs hostname; };
      home-manager.users.amiceli.imports = [
        (self + "/hosts/common/home.nix")
        (self + "/hosts/mac/home.nix")
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
