{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
  outputs = { self, nixpkgs, nixpkgs-old, nixpkgs-unstable, nixos-hardware, agenix, nix-darwin, nixos-wsl, home-manager, nix-homebrew, nix-flatpak, ... }@inputs:
    let
      username = "amiceli";
      mkDarwinSystem = import ./lib/mkDarwinSystem.nix {
        inherit nix-darwin nixpkgs agenix home-manager nix-homebrew inputs self;
      };
      mkNixosSystem = import ./lib/mkNixosSystem.nix {
        inherit nixpkgs nixpkgs-old nixpkgs-unstable home-manager agenix nix-flatpak inputs self;
      };
    in {
      nixosConfigurations = {
        fw13     = mkNixosSystem { hostname = "fw13";     inherit username; };
        rb14     = mkNixosSystem { hostname = "rb14";     inherit username; };
        simrig   = mkNixosSystem { hostname = "simrig";   inherit username; };
        steambox = mkNixosSystem { hostname = "steambox"; inherit username; };
        wsl      = mkNixosSystem { hostname = "wsl";      inherit username; };
      };
      darwinConfigurations = {
        air  = mkDarwinSystem { hostname = "air";  inherit username; };
        mini = mkDarwinSystem { hostname = "mini"; inherit username; };
      };
  };
}
