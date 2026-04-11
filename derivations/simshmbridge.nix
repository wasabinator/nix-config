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
    fetchSubmodules = true;
  };

  buildPhase = ''
    runHook preBuild
    mkdir -p assets
    # Linux native binaries only - Windows binary built separately
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
    description = "Shared memory bridge for sim racing titles running under Wine/Proton (Linux binaries only)";
    homepage    = "https://github.com/Spacefreak18/simshmbridge";
    license     = licenses.gpl3Only;
    platforms   = platforms.linux;
  };
}


