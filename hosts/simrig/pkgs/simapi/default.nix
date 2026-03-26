{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, patchelf
, argtable
, libuv
, libconfig
, yder
}:

stdenv.mkDerivation {
  pname = "simapi";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "simapi";
    rev = "561ff2a687efad7c781acd4400ef28c74d716ba3";
    # Run: nix-prefetch-url --unpack https://github.com/Spacefreak18/simapi/archive/master.tar.gz
    hash = "sha256-LRkm7s4R7ihFBWVC7w9odzLcOvgJQb4Ude15QWWnOy4=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DARGTABLE3_INCLUDE_DIR=${argtable}/include"
    "-DARGTABLE3_LIBRARY=${argtable}/lib/libargtable3.so"
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
    "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"
    "-DCMAKE_INSTALL_RPATH=${placeholder "out"}/lib:${placeholder "out"}/lib64"
  ];

  buildInputs = [ argtable libuv libconfig yder ];
  nativeBuildInputs = [ cmake pkg-config patchelf ];

  # simapi builds both a shared library (libsimapi.so) and the simd daemon.
  # We install all of them so downstream derivations (monocoque, simshmbridge)
  # can reference the headers, and so simd can be used as a systemd service.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/include

    # Headers
    cp -r $src/include/. $out/include/

    # Library — copy and create versioned symlink to match soname
    cp libsimapi.so $out/lib/libsimapi.so
    ln -s $out/lib/libsimapi.so $out/lib/libsimapi.so.1

    # simd binary
    [ -f simd/simd ] && cp simd/simd $out/bin/simd

    # Set RPATH on simd so it finds libsimapi.so.1 at runtime
    patchelf --set-rpath ${lib.makeLibraryPath [ libuv libconfig yder argtable ]}:$out/lib $out/bin/simd

    runHook postInstall
  '';

  meta = with lib; {
    description = "Racing simulator telemetry mapping daemon and shared library";
    homepage    = "https://github.com/Spacefreak18/simapi";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
  };
}
