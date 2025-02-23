{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };
  outputs = { self, nixpkgs, nixos-hardware, home-manager, brew-nix, mac-app-util, ... }@inputs: {

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

    # mac mini m4
    homeConfigurations.macm4 = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        
      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        mac-app-util.homeManagerModules.default
        ({ ... }: {
          nixpkgs.overlays = [ brew-nix.overlays.default ];
        })
        ./hosts/mac-m4/home.nix 
      ];
    };
  };
}
