{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
  outputs = { self, nixpkgs, nixos-hardware, nix-darwin, nixos-wsl, home-manager, brew-nix, mac-app-util, ... }@inputs: {
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
    darwinConfigurations.mini = nix-darwin.lib.darwinSystem {
      pkgs = import nixpkgs { 
        system = "aarch64-darwin"; 
        config.allowUnfree = true;
        overlays = [ brew-nix.overlays.default ];
      };
      modules = [
        ./hosts/mini/configuration.nix
        home-manager.darwinModules.home-manager {
          nixpkgs.overlays = [ brew-nix.overlays.default ];
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            mac-app-util.homeManagerModules.default
            ./common/home.nix
            ./hosts/mini/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
      specialArgs = {
        inherit self inputs nix-darwin;
      };
    };

    # NixOS-WSL configuration
    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      #system = "x86_64-linux";
      pkgs = import nixpkgs { 
        system = "x86_64-linux"; 
        config.allowUnfree = true;
      };
      modules = [
        nixos-wsl.nixosModules.default
        {
          system.stateVersion = "24.11";
          wsl.defaultUser = "amiceli";
          wsl.enable = true;
        }
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            ./common/home.nix 
            ./hosts/wsl/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
    };
  };
}
