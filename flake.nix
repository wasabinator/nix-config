{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
  };
  outputs = { self, nixpkgs, nixos-hardware, home-manager }@inputs: {
    # frame.work 13
    nixosConfigurations.fw13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        nixos-hardware.nixosModules.framework-13-7040-amd
        ./hosts/fw13/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true; # makes hm use nixos's pkgs value
          home-manager.extraSpecialArgs = { inherit inputs; }; # allows access to flake inputs in hm modules
          home-manager.users.amiceli.imports = [ ./hosts/fw13/home.nix ];
          home-manager.backupFileExtension = ".bak";
        }
      ];
    };
  };
}
