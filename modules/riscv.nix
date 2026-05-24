{
  flake.modules.nixos.riscv = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgsCross.riscv64.buildPackages.binutils
      pkgsCross.riscv64.buildPackages.gcc
    ];
  };
  flake.modules.darwin.riscv = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgsCross.riscv64.buildPackages.binutils
      pkgsCross.riscv64.buildPackages.gcc
    ];
  };
}
