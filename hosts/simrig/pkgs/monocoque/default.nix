{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, simapi          # provides headers + SIMAPI.DAT memory map
, libserialport   # Arduino serial devices
, libconfig       # config file parsing
, libuv           # base event loop
, argtable        # CLI argument parsing (argtable2 API)
, hidapi          # USB HID devices (Moza R5, etc.)
, lua5_4          # Lua scripting for custom serial device effects
, libxdg-basedir  # XDG config directory support
, pipewire        # PulseAudio compat layer for haptic audio output
, libxml2         # XML parsing (RevBurner tachometer config)
}:

stdenv.mkDerivation rec {
  pname = "monocoque";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "monocoque";
    rev = "master";
    # Run: nix-prefetch-url --unpack https://github.com/Spacefreak18/monocoque/archive/master.tar.gz
    hash = lib.fakeHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    simapi
    libserialport
    libconfig
    libuv
    argtable
    hidapi
    lua5_4
    libxdg-basedir
    pipewire       # provides libpulse — used for haptic bass shaker audio output
    libxml2
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
