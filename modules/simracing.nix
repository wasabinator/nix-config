{ config, ... }: {
  flake.modules.nixos.simracing = { pkgs, ... }: {
    imports = with config.flake.modules.nixos; [
      monocoque
      simapi
    ];

    environment.systemPackages = with pkgs; [
      wget
      unzip
      (pkgs.writeShellScriptBin "ac-setup" ''
        #!/bin/sh
        echo "Running Assetto Corsa Linux setup..."
        echo "This script will:"
        echo "  1. Install Proton-GE 9-20"
        echo "  2. Install Content Manager"
        echo "  3. Install Custom Shaders Patch"
        echo ""
        curl -Os https://raw.githubusercontent.com/sihawido/assettocorsa-linux-setup/main/assettocorsa-linux-setup.sh
        bash assettocorsa-linux-setup.sh
      '')
    ];
  };
}
