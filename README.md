# nix-config

My Nix config for various systems

## Initial setup

- Ensure your /etc/ssh/ssh_host_ed25519_key (unique to host) and ~/.ssh/agenix (unique to repo) keys exist.

## macOS initial setup

- Install Determinate Nix Installer, via `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`.

## NixOS and macOS hosts

- Initial build: `curl -fsSL https://raw.githubusercontent.com/wasabinator/nix-config/main/build.sh | bash -s $HOST`
- Subsequent builds: `./build.sh $HOST`
