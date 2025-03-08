{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  outputs = { self, nixpkgs, nixos-hardware, nix-darwin, home-manager, brew-nix, mac-app-util, ... }@inputs: {
    # frame.work 13
    nixosConfigurations.fw13 = nixpkgs.lib.nixosSystem {
      pkgs = import nixpkgs { 
        system = "x86_64-linux"; 
        config.allowUnfree = true;
      };
      modules = [ 
        nixos-hardware.nixosModules.framework-13-7040-amd
        ./hosts/fw13/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            ./common/home.nix 
            ./hosts/fw13/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
    };

    # mac mini m4
    darwinConfigurations.macm4 = nix-darwin.lib.darwinSystem {
      pkgs = import nixpkgs { 
        system = "aarch64-darwin"; 
        config.allowUnfree = true;
        overlays = [ brew-nix.overlays.default ];
      };
      modules = [
        (import ./hosts/mac-m4/configuration.nix { inherit nixpkgs nix-darwin; })
        home-manager.darwinModules.home-manager {
          nixpkgs.overlays = [ brew-nix.overlays.default ];
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            mac-app-util.homeManagerModules.default
            ./common/home.nix
            ./hosts/mac-m4/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
    };
  };
}
