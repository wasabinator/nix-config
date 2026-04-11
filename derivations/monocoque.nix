{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, simapi          # provides headers + SIMAPI.DAT memory map
, libserialport   # Arduino serial devices
, libconfig       # config file parsing
, libuv           # base event loop
, argtable2       # CLI argument parsing (argtable2 API)
, hidapi          # USB HID devices (Moza R5, etc.)
, lua5_4          # Lua scripting for custom serial device effects
, libxdg_basedir  # XDG config directory support
, pipewire        # PulseAudio compat layer for haptic audio output
, libxml2         # XML parsing (RevBurner tachometer config)
, libpulseaudio   # Pulse audio
}:

stdenv.mkDerivation rec {
  pname = "monocoque";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "monocoque";
    rev = "10c172d3e1190a25361bed93f0b01c4d8540ebcf";
    # Run: nix-prefetch-url --unpack https://github.com/Spacefreak18/monocoque/archive/master.tar.gz
    hash = "sha256-BwCqMv5Exm9VYp4p2nlVQT4/+xVPWAbZ+1Cj4ceMuwk=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DARGTABLE2_INCLUDE_DIR=${argtable2}/include"
    "-DARGTABLE2_LIBRARY=${argtable2}/lib/libargtable2.so"
    "-DCMAKE_C_FLAGS=-I${libxml2.dev}/include/libxml2"
  ];
  nativeBuildInputs = [ cmake pkg-config ];

  dontCheckForBrokenSymlinks = true; # ignore arduino sketch issues
  
  buildInputs = [
    simapi
    libserialport
    libconfig
    libuv
    argtable2
    hidapi
    lua5_4
    libxdg_basedir
    pipewire       # provides libpulse — used for haptic bass shaker audio output
    libxml2
    libxml2.dev
    libpulseaudio
  ];

  # Point CMake at our Nix-provided simapi rather than the git submodule.
  # The submodule path reference in CMakeLists.txt needs to resolve to our
  # simapi derivation's include and lib dirs.
  # TODO: verify the exact submodule path string in CMakeLists.txt and adjust
  # the substituteInPlace pattern if it differs from "submodules/simapi".
  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace "submodules/simapi" "${simapi}"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Main device manager daemon
    cp monocoque $out/bin/

    # TUI configuration manager (built alongside main binary)
    [ -f monocoque-manager ] && cp monocoque-manager $out/bin/

    # Install Arduino sketches to share/ so the user can flash them with arduino-cli.
    # Sketches: simwind (wind sim), shiftlights (shift indicator LEDs), simhaptic (haptic motor)
    mkdir -p $out/share/monocoque/arduino
    cp -r $src/src/arduino/. $out/share/monocoque/arduino/

    # Install example config files to share/
    mkdir -p $out/share/monocoque
    find $src -name "*.config" -o -name "*.conf" | \
      xargs -I{} cp {} $out/share/monocoque/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "Device manager for driving and flight simulators on Linux";
    longDescription = ''
      Monocoque reads telemetry from sim racing titles via simapi and drives
      physical devices: Arduino serial (sim lights, wind, haptic effects),
      USB HID wheels and pedals (including Moza R5), and haptic bass shakers
      via a USB audio card. Supports AC, ACC, LMU/rF2, and more.
    '';
    homepage    = "https://github.com/Spacefreak18/monocoque";
    license     = licenses.gpl2Only;
    platforms   = platforms.linux;
    maintainers = [];
  };
}
