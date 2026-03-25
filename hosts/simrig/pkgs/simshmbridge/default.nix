{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "simshmbridge";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "simshmbridge";
    rev = "740f64da83a3745c254778ac492f66bd7a972f9a";
    hash = "sha256-l1pz66U57Sxo9RpTHVT+h2RKcw6YnynXyZPB7iXeLm4=";
    fetchSubmodules = false; # no submodules needed
  };

  nativeBuildInputs = [ ];

  # Only build the native Linux binaries, skip the .exe cross-compilation
  # for now since mingw cross-compilation in Nix requires more setup.
  # The .exe files can be built separately if needed.
  buildPhase = ''
    runHook preBuild
    mkdir -p assets
    gcc -DASSETTOCORSA -Wall -Os createsimshm.c -o assets/acshm
    gcc -DASSETTOCORSA -Wall -Os bridge.c -o assets/achandle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp assets/acshm $out/bin/
    cp assets/achandle $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Shared memory bridge for sim racing titles running under Wine/Proton";
    homepage    = "https://github.com/Spacefreak18/simshmbridge";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
  };
}

