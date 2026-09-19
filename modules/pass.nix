{ config, ... }:
{
  # Shared between nixos and darwin
  flake.modules.generic.pass = { pkgs, ... }: {
    home = {
      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [
          exts.pass-otp
          (pkgs.stdenvNoCC.mkDerivation {
            pname = "pass-meta";
            version = "0-unstable";
            src = pkgs.fetchFromGitHub {
              owner = "rjekker";
              repo = "pass-extension-meta";
              rev = "2942bff7bc088422e780a96e5b1139db8508f386";
              hash = "sha256-O/YatXOA4EiGnGkemmGd6pVCNVwrtDeLoDq9PRSlGY4=";
            };
            dontBuild = true;
            # meta.bash shells out to perl, so pin it rather than trusting PATH
            postPatch = ''
              substituteInPlace src/meta.bash \
                --replace-fail '| perl -l' '| ${pkgs.perl}/bin/perl -l'
            '';
            installPhase = ''
              runHook preInstall
              install -Dm755 src/meta.bash $out/lib/password-store/extensions/meta.bash
              runHook postInstall
            '';
          })
        ]);
      };

      # No key material lives in this repo. The public key and ownertrust
      # both come from the runtime import done by pass-setup.
      programs.gpg.enable = true;

      # Run manually once per machine. Needs pass-key-fetch (defined per
      # platform below) to emit the passphrase-protected encryption subkey
      # on stdout. Imports it, marks it ultimately trusted, then clones the
      # password store from the NAS. Re-running is safe.
      home.packages = with pkgs; [
        (writeShellApplication {
          name = "pass-setup";
          runtimeInputs = [ gnupg gawk git ];
          text = ''
            status=$(pass-key-fetch | gpg --status-fd 1 --import)

            printf '%s\n' "$status" \
              | awk '/^\[GNUPG:\] IMPORT_OK/ { print $4 }' \
              | sort -u \
              | while read -r fpr; do
                  echo "$fpr:6:" | gpg --import-ownertrust
                done

            if [ -d "$HOME/.password-store/.git" ]; then
              echo "password store already cloned, skipping"
            else
              git clone \
                ssh://amiceli@mitsukoshi.local:1022/volume2/git/pass.git \
                "$HOME/.password-store"
            fi
          '';
        })
      ];
    };
  };

  flake.modules.nixos.pass = { pkgs, ... }: {
    imports = [ config.flake.modules.generic.pass ];

    home = {
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-gnome3;
        defaultCacheTtl = 3600;
        maxCacheTtl = 28800;
      };

      home.packages = with pkgs; [
        # pass -c uses wl-copy under Wayland (Niri)
        wl-clipboard

        # Streams the key from the NAS at runtime, never via the Nix store
        (writeShellApplication {
          name = "pass-key-fetch";
          runtimeInputs = [ samba ];
          text = ''
            # smbclient writes its "Password for ..." prompt to stdout, which
            # would corrupt the key stream. Read the password ourselves
            # (prompt goes to stderr) and hand it over via the environment.
            read -rsp "SMB password for $USER@mitsukoshi.local: " PASSWD </dev/tty
            echo >&2
            export PASSWD

            smbclient --client-protection=encrypt -U "$USER" \
              //mitsukoshi.local/amiceli \
              -c 'get keys/pass-privatekey.asc -'
          '';
        })
      ];
    };
  };

  flake.modules.darwin.pass = { pkgs, ... }: {
    imports = [ config.flake.modules.generic.pass ];

    home = {
      # gpg starts the agent on demand on macOS, so just point it at pinentry-mac
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
        default-cache-ttl 3600
        max-cache-ttl 28800
      '';

      # Requires the NAS share mounted in Finder first
      # (smb://mitsukoshi.local/amiceli)
      home.packages = with pkgs; [
        (writeShellApplication {
          name = "pass-key-fetch";
          text = ''
            cat /Volumes/amiceli/keys/pass-privatekey.asc
          '';
        })
      ];
    };
  };
}
