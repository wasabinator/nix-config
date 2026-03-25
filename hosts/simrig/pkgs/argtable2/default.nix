{ pkgs
, lib
, stdenv
, fetchurl
, autoreconfHook
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "argtable2";
  version = "2.13";

  src = fetchurl {
    url = "https://sourceforge.net/projects/argtable/files/argtable/argtable-2.13/argtable2-13.tar.gz";
    hash = "sha256-j3fop87VMBr24i9HMC/bw7H/QfK4PEPHeuXKBBdx3b8=";
  };

  patches = [
    (pkgs.writeText "argtable2-ctype.patch" ''
      --- a/src/arg_int.c
      +++ b/src/arg_int.c
      @@ -31,0 +32 @@
      +#include <ctype.h>
    '')
  ];

  nativeBuildInputs = with pkgs; [
    autoreconfHook
    pkg-config
  ];
  
  meta = with lib; {
    description = "ANSI C library for parsing GNU style command line arguments";
    homepage    = "http://argtable.sourceforge.net/";
    license     = licenses.lgpl2Plus;
    platforms   = platforms.linux;
  };
}

