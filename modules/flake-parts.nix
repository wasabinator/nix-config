{ inputs, lib, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = {};
  };
}
