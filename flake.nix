{
  nixConfig.extra-experimental-features = "nix-command flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #home-manager-unstable = {
    #  url = "github:nix-community/home-manager/master";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    paneru = {
      url = "github:karinushka/paneru";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
      flake.meta.owner = {
        username = "amiceli";
        name = "Tony Miceli";
        email = "6946957+wasabinator@users.noreply.github.com";
      };
    };
  }
