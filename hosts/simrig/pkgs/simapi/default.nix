{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
}:

stdenv.mkDerivation {
  pname = "simapi";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "simapi";
    rev = "561ff2a687efad7c781acd4400ef28c74d716ba3";
    # Run: nix-prefetch-url --unpack https://github.com/Spacefreak18/simapi/archive/master.tar.gz
    hash = "sha256-KGJgomo0HCkv/WzuhJFesJZ9hfTL3lPKpA4W8scIaLQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];

  # simapi builds both a shared library (libsimapi.so) and the simd daemon.
  # We install all of them so downstream derivations (monocoque, simshmbridge)
  # can reference the headers, and so simd can be used as a systemd service.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/include

    # Headers
    cp -r $src/include/. $out/include/

    # Shared library
    [ -f libsimapi.so ] && cp libsimapi.so $out/lib/

    # simd daemon binary
    [ -f simd ] && cp simd $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Racing simulator telemetry mapping daemon and shared library";
    homepage    = "https://github.com/Spacefreak18/simapi";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
  };
}
