{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };
  outputs = { self, nixpkgs, nixos-hardware, nix-darwin, nixos-wsl, home-manager, nix-homebrew, nix-flatpak, ... }@inputs: {
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
            nix-flatpak.homeManagerModules.nix-flatpak
            ./hosts/common/home.nix 
            ./hosts/fw13/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
    };

    # gaming pc
    nixosConfigurations.steambox = nixpkgs.lib.nixosSystem {
      pkgs = import nixpkgs { 
        system = "x86_64-linux"; 
        config.allowUnfree = true;
      };
      modules = [ 
        ./hosts/steambox/configuration.nix
      ];
    };

    # mac mini m4
    darwinConfigurations.mini = nix-darwin.lib.darwinSystem {
      pkgs = import nixpkgs { 
        system = "aarch64-darwin"; 
        config.allowUnfree = true;
      };
      modules = [
        ./hosts/mac/mini/configuration.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            ./hosts/common/home.nix
            ./hosts/mac/common/home.nix
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
    };

    # macbook air m3
    darwinConfigurations.air = nix-darwin.lib.darwinSystem {
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      modules = [
        ./hosts/mac/air/configuration.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.amiceli.imports = [
            ./hosts/common/home.nix
            ./hosts/mac/common/home.nix
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
            ./hosts/common/home.nix 
            ./hosts/wsl/home.nix
          ];
          home-manager.backupFileExtension = "home-manager-backup";
        }
      ];
    };
  };
}
