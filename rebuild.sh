#!/bin/bash

DARWIN_HOSTS=("air" "mini")
NIXOS_HOSTS=("fw13" "steambox" "wsl")

HOST=$1

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 <host>"
  echo "Darwin hosts: ${DARWIN_HOSTS[@]}"
  echo "NixOS hosts:  ${NIXOS_HOSTS[@]}"
  exit 1
elif [[ " ${DARWIN_HOSTS[@]} " =~ " ${HOST} " ]]; then
  sudo darwin-rebuild switch --flake .#$HOST
elif [[ " ${NIXOS_HOSTS[@]} " =~ " ${HOST} " ]]; then
  sudo nixos-rebuild switch --flake .#$HOST
else
  echo "Unknown host: $HOST"
  echo "Darwin hosts: ${DARWIN_HOSTS[@]}"
  echo "NixOS hosts:  ${NIXOS_HOSTS[@]}"
  exit 1
fi
