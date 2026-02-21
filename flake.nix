{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  outputs = { self, nixpkgs, nixos-hardware, agenix, nix-darwin, nixos-wsl, home-manager, nix-homebrew, nix-flatpak, ... }@inputs:
    let
      mkDarwinSystem = import ./lib/mkDarwinSystem.nix {
        inherit nix-darwin nixpkgs agenix home-manager nix-homebrew inputs self;
      };
      mkNixosSystem = import ./lib/mkNixosSystem.nix {
        inherit nixpkgs home-manager agenix inputs self;
      };
    in {
      nixosConfigurations = {
        fw13 = mkNixosSystem {
          hostname = "fw13";
          extraModules = [ nixos-hardware.nixosModules.framework-13-7040-amd ];
          homeModules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            (self + "/hosts/fw13/home.nix")
          ];
        };
        rb14 = mkNixosSystem {
          hostname = "rb14";
          extraModules = [ ];
          homeModules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            (self + "/hosts/rb14/home.nix")
          ];
        };
        steambox = mkNixosSystem {
          hostname = "steambox";
        };
        wsl = mkNixosSystem {
          hostname = "wsl";
          extraModules = [
            nixos-wsl.nixosModules.default
            {
              system.stateVersion = "24.11";
              wsl.defaultUser = "amiceli";
              wsl.enable = true;
            }
          ];
          homeModules = [ (self + "/hosts/wsl/home.nix") ];
        };
      };
      darwinConfigurations = {
        air = mkDarwinSystem { hostname = "air"; };
        mini = mkDarwinSystem { hostname = "mini"; };
      };
    };
}
