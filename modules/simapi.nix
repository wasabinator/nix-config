{
  lib,
  config,
  ...
}:

let
  username = config.flake.meta.owner.username;
in

{
  flake.modules.nixos.simapi =
    { pkgs, ... }:
    {
      home = {
        home.file = {
          "simd/simd.config" = {
            source =
              pkgs.fetchFromGitHub {
                owner = "wasabinator";
                repo = "simapi";
                rev = "561ff2a687efad7c781acd4400ef28c74d716ba3";
                hash = "sha256-LRkm7s4R7ihFBWVC7w9odzLcOvgJQb4Ude15QWWnOy4=";
              }
              + "/simd/conf/simd.config";
          };
        };

        systemd.user.services.simd = {
          Unit = {
            Description = "SimAPI Daemon - Racing Simulator Telemetry Service";
            Documentation = "https://github.com/wasabinator/simapi";
            After = [ "default.target" ];
          };
          Service = {
            Type = "simple";
            Environment = "LD_LIBRARY_PATH=/home/${username}/.local/lib";
            ExecStart = "/etc/profiles/per-user/${username}/bin/simd -n -vv";
            Restart = "on-failure";
            RestartSec = "5";
            StandardOutput = "journal";
            StandardError = "journal";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };

        home.packages = with pkgs; [
          (pkgs.stdenv.mkDerivation {
            pname = "simapi-all";
            version = "561ff2a687efad7c781acd4400ef28c74d716ba3-20";

            src = pkgs.fetchFromGitHub {
              owner = "wasabinator";
              repo = "simapi";
              rev = "561ff2a687efad7c781acd4400ef28c74d716ba3";
              hash = "sha256-LRkm7s4R7ihFBWVC7w9odzLcOvgJQb4Ude15QWWnOy4=";
              fetchSubmodules = true;
            };

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.pkg-config
              pkgs.patchelf
              pkgs.makeWrapper
            ];
            buildInputs = with pkgs; [
              argtable
              libconfig
              libuv
              yder
            ];

            postPatch = ''
              # Debug: list the files we're patching
              ls simd/simd.c
              # Patch simd to use wine64 instead of wine (both paths)
              sed -i 's|dist/bin/wine|dist/bin/wine64|g' simd/simd.c
              sed -i 's|files/bin/wine|files/bin/wine64|g' simd/simd.c
              # Verify the patch
              grep -n "wine64" simd/simd.c || echo "WARNING: patch may not have worked"
            '';

            cmakeFlags = [
              "-DCMAKE_BUILD_TYPE=RELEASE"
              "-DCMAKE_INSTALL_RPATH=$out/lib"
            ];

            installPhase = ''
              mkdir -p $out/bin
              mkdir -p $out/lib
              cp ./simd/simd $out/bin/simd
              cp ./libsimapi.so* $out/lib/
              cp ${pkgs.libuv}/lib/libuv.so* $out/lib/
              cp ${pkgs.yder}/lib/libyder.so* $out/lib/
              cp ${pkgs.argtable}/lib/libargtable*.so* $out/lib/
              cp ${pkgs.libconfig}/lib/libconfig*.so* $out/lib/
              patchelf --set-rpath "$out/lib" $out/bin/simd
              wrapProgram "$out/bin/simd" --prefix LD_LIBRARY_PATH : "$out/lib"
            '';

            meta = with lib; {
              description = "Simd";
              homepage = "https://github.com/wasabinator/simapi";
              license = licenses.gpl3Only;
              platforms = platforms.linux;
            };
          })

          (pkgs.stdenv.mkDerivation {
            pname = "acbridge";
            version = "0.1.0";

            src = pkgs.fetchurl {
              url = "https://github.com/Spacefreak18/simshmbridge/releases/download/0.1.0/compatbinaries.zip";
              sha256 = "sha256-rQWcUvchRnpyhF2tVCKRBmOQlB0W1OYv9dk6ywgcUMA=";
            };

            nativeBuildInputs = [ pkgs.unzip ];
            dontUnpack = true;

            installPhase = ''
              runHook preInstall
              mkdir -p extracted
              unzip -o "$src" -d extracted
              mkdir -p $out/bin
              cp extracted/acbridge.exe $out/bin/
              cp extracted/pcars2bridge.exe $out/bin/
              cp extracted/rf2bridge.exe $out/bin/ 2>/dev/null || true
              rm -rf extracted
              runHook postInstall
            '';

            postInstall = ''
              cat > $out/bin/acbridge.exe <<'WRAPPER'
              #!/bin/sh
              if [ ! -L "/home/${username}/.local/share/simshmbridge/acbridge.exe" ]; then
                DIR="$(dirname "$(readlink -f "$0")")"
                mkdir -p "/home/${username}/.local/share/simshmbridge"
                ln -sf "$DIR/acbridge.exe" "/home/${username}/.local/share/simshmbridge/"
                ln -sf "$DIR/pcars2bridge.exe" "/home/${username}/.local/share/simshmbridge/" 2>/dev/null || true
                ln -sf "$DIR/rf2bridge.exe" "/home/${username}/.local/share/simshmbridge/" 2>/dev/null || true
              fi
              exec "/home/${username}/.local/share/simshmbridge/acbridge.exe" "$@"
              WRAPPER
              chmod +x $out/bin/acbridge.exe
            '';

            meta = with lib; {
              description = "Assetto Corsa shared memory bridge";
              homepage = "https://github.com/spacefreak18/simshmbridge";
              license = licenses.gpl3Only;
              platforms = platforms.linux;
            };
          })
        ];
      };
    };
}
