# nix-config

My Nix config for various systems

## NixOS hosts

Build with `sudo nixos-rebuild switch --flake .#hostname`

## macOS hosts

Installation:

- Install Determinate Nix Installer, choosing no at the first option
- Setup nix-darwin with: `nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#hostname`
- Now config is managed via `darwin-rebuild`

Build with `darwin-rebuild switch --flake .#hostname`

