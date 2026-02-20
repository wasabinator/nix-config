#!/bin/bash

REPO_HTTPS="https://github.com/wasabinator/nix-config.git"
REPO_SSH="git@github.com:wasabinator/nix-config.git"

DARWIN_HOSTS=("air" "mini")
NIXOS_HOSTS=("fw13" "steambox" "wsl")

HOST=$1

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 <host>"
  echo "Darwin hosts: ${DARWIN_HOSTS[@]}"
  echo "NixOS hosts:  ${NIXOS_HOSTS[@]}"
  echo ""
  echo "Bootstrap from scratch:"
  echo "  curl -fsSL https://raw.githubusercontent.com/wasabinator/nix-config/main/build.sh | bash -s <host>"
  exit 1
fi

# validate host
if [[ ! " ${DARWIN_HOSTS[@]} ${NIXOS_HOSTS[@]} " =~ " ${HOST} " ]]; then
  echo "Unknown host: $HOST"
  echo "Darwin hosts: ${DARWIN_HOSTS[@]}"
  echo "NixOS hosts:  ${NIXOS_HOSTS[@]}"
  exit 1
fi

do_rebuild() {
  if [[ " ${DARWIN_HOSTS[@]} " =~ " ${HOST} " ]]; then
    if command -v darwin-rebuild &> /dev/null; then
      sudo darwin-rebuild switch --flake .#$HOST
    else
      echo "darwin-rebuild not found, running initial nix-darwin install..."
      sudo -H nix run nix-darwin \
        --extra-experimental-features nix-command \
        --extra-experimental-features flakes \
        -- switch --flake .#$HOST
    fi
  else
    sudo nixos-rebuild switch --flake .#$HOST
  fi
}

# check if we are already inside the repo
if [[ -f flake.nix ]]; then
  echo "Running rebuild for $HOST from existing repo..."
  do_rebuild
  exit 0
fi

# bootstrap from scratch
if [[ ! -f ~/.ssh/agenix ]]; then
  echo "Error: ~/.ssh/agenix not found"
  echo "Please restore your agenix private key before running this script"
  exit 1
fi

if [[ "$(stat -c %a ~/.ssh/agenix 2>/dev/null || stat -f %A ~/.ssh/agenix)" != "600" ]]; then
  echo "Fixing permissions on ~/.ssh/agenix..."
  chmod 600 ~/.ssh/agenix
fi

if [[ -d nix-config ]]; then
  echo "Error: nix-config directory already exists in $(pwd)"
  exit 1
fi

echo "Starting bootstrap for host: $HOST"

nix shell github:ryantm/agenix nixpkgs#git --command bash -c "
  set -e

  echo 'Cloning nix-config...'
  git clone $REPO_HTTPS nix-config
  cd nix-config

  echo 'Switching remote to SSH...'
  git remote set-url origin $REPO_SSH

  echo 'Running rebuild for $HOST...'
  ./build.sh $HOST
"

echo "Bootstrap complete! You may want to verify SSH access to GitHub:"
echo "  ssh -T git@github.com"
