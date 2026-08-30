{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "deepseek-harness";
      version = "0.1.2-alpha.2";

      src = pkgs.fetchFromGitHub {
        owner = "deepseek-ai";
        repo = "deepseek-harness";
        rev = "dsh-v0.1.2-alpha.2";
        hash = "sha256-fDLyk09boJGNXVMOBnln2dY1ZSETXGpFBHUVqFBLRk4=";
      };

      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit pname version src;
        fetcherVersion = 4;
        hash = "sha256-KK34f9oTm/ofvAR9VV/FGnR1jJAQUyFzQMz7a/Xv6VE=";
      };
    in
    {
      packages.deepseek-harness = pkgs.stdenv.mkDerivation (finalAttrs: {
        inherit pname version src;

        inherit pnpmDeps;

        passthru.updateVersionRegex = "dsh-v(.*)";

        nativeBuildInputs = with pkgs; [
          makeWrapper
          nodejs
          pnpm
          pnpmConfigHook
        ];

        # Scripts are ignored by pnpmConfigHook's install; the workspace has
        # no native (node-gyp/napi) postinstall steps of its own, so nothing
        # extra needs to be rebuilt here (unlike e.g. sharp/canvas elsewhere).
        buildPhase = ''
          runHook preBuild
          pnpm run build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          libDir=$out/lib/deepseek-harness
          mkdir -p $libDir
          cp -r . $libDir/

          # Trim dev-only, non-workspace directories that apps/cli's runtime
          # graph never resolves into. website/, examples/, and python/ stay:
          # they are pnpm workspace members with live node_modules symlinks
          # into them, so removing them post-install dangles those links and
          # fails pnpm's own fixup/shebang pass.
          rm -rf $libDir/{.git,.github,.agents,.claude,docs,scripts}

          # dsh's Cordis loader resolves/HMRs plugins through Node's internal
          # ESM loader (vendor/loader/src/internal.ts) so it can control the
          # parent URL bare specifiers resolve against; that internal API is
          # only reachable with --expose-internals. Without it, imports
          # silently resolve relative to the loader's own file instead of the
          # profile directory and every non-directly-linked plugin 404s.
          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/dsh \
            --add-flags "--expose-internals" \
            --add-flags "$libDir/apps/cli/lib/bin.js"

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Open-source agent harness developed by DeepSeek AI";
          homepage = "https://github.com/deepseek-ai/deepseek-harness";
          license = licenses.mit;
          mainProgram = "dsh";
          platforms = platforms.unix;
        };
      });
    };
}
