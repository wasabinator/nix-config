{ lib
, stdenv
, wineWow64Packages
}:

let
  baseWine = wineWow64Packages.full;
in
stdenv.mkDerivation {
  pname = "wine-wow64-custom";
  version = baseWine.version;
  
  dontUnpack = true;
  dontBuild = true;
  
  installPhase = ''
    mkdir -p $out/{bin,lib,share}
    
    # Copy all the wine binaries from base package
    cp ${baseWine}/bin/* $out/bin/ 2>/dev/null || true
    
    # Copy libraries and share directories
    cp -r ${baseWine}/lib/* $out/lib/ 2>/dev/null || true
    cp -r ${baseWine}/share/* $out/share/ 2>/dev/null || true
    
    # Ensure wine wrapper script is executable
    chmod +x $out/bin/wine 2>/dev/null || true
    
    # Create wine64 as a symlink to wine
    # Wine internally detects binary architecture and routes accordingly
    ln -sf wine $out/bin/wine64
    
    # Create wine32 as well for completeness
    ln -sf wine $out/bin/wine32
  '';
  
  postInstall = ''
    # Verify wine64 exists
    if [ ! -L $out/bin/wine64 ]; then
      echo "ERROR: wine64 symlink not created"
      ls -la $out/bin/
      exit 1
    fi
    echo "Successfully created wine64 symlink:"
    ls -la $out/bin/wine*
  '';
  
  meta = with lib; {
    description = "Wine with WoW64 support with explicit wine64 binary";
    homepage = baseWine.meta.homepage or "https://www.winehq.org";
    license = baseWine.meta.license or licenses.lgpl21Plus;
    platforms = baseWine.meta.platforms or platforms.linux;
  };
}
