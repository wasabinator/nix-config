{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libuv
, libconfig
, yder
, argtable2
}:

stdenv.mkDerivation {
  pname = "simapi";
  version = "unstable-2025";

  src = fetchFromGitHub {
    owner = "Spacefreak18";
    repo = "simapi";
    rev = "99ade2fc10ea7c3f1f04e8a3573a8160c1578c4e";
    hash = "sha256-SXZLGWRrlqJg78SKcbh2UBrj8jHsoa8BrM3oG+w2vhM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libuv libconfig yder argtable2 ];

  cmakeFlags = [
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
    "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"
    "-DINSTALL_SYSTEMD_SERVICE=OFF"
    "-DINSTALL_DEFAULT_CONFIG=OFF"
  ];

  meta = with lib; {
    description = "Racing simulator telemetry mapping daemon and shared library";
    homepage = "https://github.com/Spacefreak18/simapi";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
