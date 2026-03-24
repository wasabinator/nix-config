{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, simapi
  # mingw-w64 cross compiler — needed to build the .exe bridge files that
  # run inside game Proton prefixes to map shared memory across the boundary.
, pkgsCross
}:

let
  # We need both a native build (createsimshm, bridge Linux binaries)
  # and a cross-compiled Windows build (simshmbridge.exe, acbridge.exe etc.)
  # The .exe files are what actually run inside Proton prefixes.
  mingw = pkgsCross.mingwW64.stdenv;
in

stdenv.mkDerivation rec {
  pname = "simshmbridge";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "simshmbridge";
    rev = "master";
    # Run: nix-prefetch-url --unpack https://github.com/Spacefreak18/simshmbridge/archive/master.tar.gz
    hash = lib.fakeHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ simapi ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace "submodules/simapi" "${simapi}"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/simshmbridge

    # Native Linux binaries
    [ -f createsimshm ] && cp createsimshm $out/bin/
    [ -f bridge ]       && cp bridge $out/bin/

    # .exe bridge files — these are copied into Proton prefixes at game setup time.
    # Usage: run the appropriate .exe inside the game's Proton prefix alongside
    # simd (or acshm/createsimshm) to bridge shared memory across the Wine boundary.
    #
    # Per-game bridge files:
    #   acbridge.exe      — Assetto Corsa (AppID 244210)
    #   accbridge.exe     — Assetto Corsa Competizione
    #   pcars2bridge.exe  — Project Cars 2 (and derivatives)
    #
    # See configuration.nix comments for Steam launch command integration.
    find . -name "*.exe" -exec cp {} $out/share/simshmbridge/ \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Shared memory bridge for sim racing titles running under Wine/Proton";
    longDescription = ''
      simshmbridge creates Linux shared memory files for sim racing titles and
      maps them into Wine/Proton prefixes, allowing native Linux tools like
      monocoque to read telemetry from games that use Windows shared memory
      APIs (CreateFileMapping/MapViewOfFile) rather than UDP.

      The preferred modern alternative is simd (from the simapi repo), which
      creates zeroed stubs of all supported memory files at boot and is
      sim-process-aware. Use simshmbridge .exe files when a per-game bridge
      is still needed (e.g. AC with an older Proton version).
    '';
    homepage    = "https://github.com/Spacefreak18/simshmbridge";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
    maintainers = [];
  };
}
