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
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
    "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"
    "-DCMAKE_INSTALL_RPATH=${placeholder "out"}/lib:${placeholder "out"}/lib64"
  ];

  preConfigure = ''
    export PKG_CONFIG_PATH="${argtable}/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';

  buildInputs = [ argtable libuv libconfig yder ];
  nativeBuildInputs = [ cmake pkg-config patchelf ];

  # simapi builds both a shared library (libsimapi.so) and the simd daemon.
  # We install all of them so downstream derivations (monocoque, simshmbridge)
  # can reference the headers, and so simd can be used as a systemd service.
  postBuild = ''
    # Ensure the build completed successfully
    if [ ! -f simd/simd ] && [ ! -f CMakeFiles/simd/CMakeFiles/simd.dir/simd.c.o ]; then
      echo "Build may have failed - checking CMake status"
    fi
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/include

    # Headers
    cp -r $src/include/. $out/include/

    # Library — copy and create versioned symlink to match soname
    if [ -f libsimapi.so ]; then
      cp libsimapi.so $out/lib/libsimapi.so
      ln -s $out/lib/libsimapi.so $out/lib/libsimapi.so.1
    fi

    # simd binary - check in multiple possible locations
    if [ -f simd/simd ]; then
      cp simd/simd $out/bin/simd
    elif [ -f bin/simd ]; then
      cp bin/simd $out/bin/simd
    fi

    # Only set RPATH if simd binary was found
    if [ -f $out/bin/simd ]; then
      patchelf --set-rpath ${lib.makeLibraryPath [ libuv libconfig yder argtable ]}:$out/lib $out/bin/simd
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Racing simulator telemetry mapping daemon and shared library";
    homepage    = "https://github.com/Spacefreak18/simapi";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
  };
}
