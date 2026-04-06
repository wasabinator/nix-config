{ stdenv, acpica-tools, cpio }:

stdenv.mkDerivation {
  name = "custom-dsdt";
  src = ./.;

  phases = [ "unpackPhase" "installPhase" ];

  nativeBuildInputs = [ acpica-tools cpio ];

  installPhase = ''
    mkdir -p $out/
    mkdir -p kernel/firmware/acpi
    iasl -p ./dsdt -sa ./dsdt.dsl
    cp dsdt.aml kernel/firmware/acpi/dsdt.aml
    find kernel | cpio -H newc --create > $out/dsdt.cpio
  '';
}
