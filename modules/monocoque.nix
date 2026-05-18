{ lib
, config
, pkgs
, ...
}:

let
  username = config.flake.meta.owner.username;
in

 {
   flake.modules.nixos.monocoque = { pkgs, ... }: {
     home = {
       home.packages = with pkgs; [
         (pkgs.stdenv.mkDerivation rec {
pname = "monocoque";
            version = "e3487b3652ba64285949a929f43c0762683a8b09-3";

           src = pkgs.fetchFromGitHub {
             owner = "wasabinator";
             repo = "monocoque";
             rev = version;
             hash = "sha256-5E/8zHmYqaM33S5E0mhL1CEWB8B/ER9T8aAjyrQXS4k=";
             fetchSubmodules = true;
           };

           postPatch = ''
             substituteInPlace src/monocoque/helper/parameters.c \
               --replace-warn 'argtable2.h' 'argtable3.h'

             substituteInPlace $(find . -name CMakeLists.txt) \
               --replace-warn 'argtable2' 'argtable3' \
               --replace-warn 'LIBUSB_INCLUDE_DIR /usr/include' 'LIBUSB_INCLUDE_DIR ${lib.getDev pkgs.libusb1}/include' \
               --replace-warn 'LIBXML_INCLUDE_DIR /usr/include' 'LIBXML_INCLUDE_DIR ${lib.getDev pkgs.libxml2}/include'
           '';

           nativeBuildInputs = [
             pkgs.cmake
             pkgs.pkg-config
           ];

           buildInputs = with pkgs; [
             libusb1
             hidapi
             libserialport
             libxml2
             argtable
             libconfig
             libpulseaudio
             portaudio
             jansson
             libuv
             libxdg_basedir
             lua5_3
           ];

           cmakeFlags = [
             "-DCMAKE_BUILD_TYPE=RELEASE"
             "-DUSE_PULSEAUDIO=yes"
             "-Wno-dev"
             "-DLUA_LIBRARIES=${pkgs.lua5_3}/lib/liblua.so"
             "-DLUA_INCLUDE_DIR=${pkgs.lua5_3}/include"
           ];

installPhase = ''
              mkdir -p $out/bin
              find . -name "monocoque" -type f -perm /u+x -exec cp {} $out/bin/monocoque \;
            '';

            meta = with lib; {
              description = "Device manager for driving/flight simulators";
             homepage    = "https://github.com/wasabinator/monocoque";
             license     = licenses.gpl3Only;
             platforms   = platforms.linux;
           };
         })
       ];
     };
   };
 }