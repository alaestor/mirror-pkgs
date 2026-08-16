{ ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "tweakcc";
      version = "4.3.3-unstable-2026-08-14";

      pnpm = pkgs.pnpm_10;

      src = pkgs.fetchFromGitHub {
        owner = "Piebald-AI";
        repo = "tweakcc";
        rev = "1d19576b32fb6d2158b8b4fb4a5a2d215b0632bb";
        hash = "sha256-NrhzFIFcyW4bdNadQsNFbX/8OPKMcp4y5wJlk9b6Sbk=";
      };
    in
    {
      packages.tweakcc = pkgs.stdenv.mkDerivation (finalAttrs: {
        inherit pname version src;

        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit pname version src pnpm;
          fetcherVersion = 4;
          hash = "sha256-MvEsrT3ekFqRjXh+46NEWUMpyrJJYjWgO3Oik0wsTd4=";
        };

        nativeBuildInputs = [
          pkgs.nodejs
          pnpm
          pkgs.pnpmConfigHook
          pkgs.makeWrapper
        ];

        buildPhase = ''
          runHook preBuild
          pnpm run build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/tweakcc
          cp -r dist node_modules package.json $out/lib/tweakcc/
          mkdir -p $out/bin
          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/tweakcc \
            --add-flags "$out/lib/tweakcc/dist/index.mjs"
          runHook postInstall
        '';

        meta = {
          description = "Command-line tool to customize Claude Code theme colors, thinking verbs, and more";
          homepage = "https://github.com/Piebald-AI/tweakcc";
          license = pkgs.lib.licenses.mit;
          mainProgram = "tweakcc";
          platforms = pkgs.lib.platforms.linux ++ pkgs.lib.platforms.darwin;
        };
      });
    };
}
