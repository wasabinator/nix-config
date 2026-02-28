{ config, lib, pkgs, inputs, users, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl.enable = true;
  wsl.defaultUser = builtins.head users;

  system.stateVersion = "24.11";
}
