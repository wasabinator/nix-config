# nix-config

My Nix config for various systems

## NixOS hosts

Build with `sudo nixos-rebuild switch --flake .#hostname`

## macOS hosts

Installation:

- Install Determinate Nix Installer, via `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`, and at the first prompt say no to installing the determinate service (nix-darwin will be taking this responsibility).
- Setup nix-darwin with: `nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#hostname`
- Now config is managed via `darwin-rebuild`

Build with `darwin-rebuild switch --flake .#hostname`

