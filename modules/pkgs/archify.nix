{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "archify";
      version = "2.17.0-dev.1";
      src = pkgs.fetchFromGitHub {
        owner = "tt-a1i";
        repo = "archify";
        rev = "5769acefcc2ebd696a4f9ed3ac9cb6cca1d75c70";
        hash = "sha256-Z5nWUyIlfeewex854O0fdG29npxCWYqyPTqs9TKlJQo=";
      };
    in
    {
      packages.archify-cli = pkgs.stdenvNoCC.mkDerivation {
        inherit pname version src;

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib" "$out/bin"
          cp -r archify "$out/lib/archify"
          makeWrapper ${pkgs.lib.getExe pkgs.nodejs_22} "$out/bin/archify" \
            --add-flags "$out/lib/archify/bin/archify.mjs"
          runHook postInstall
        '';

        nativeBuildInputs = [ pkgs.makeWrapper ];

        meta = with pkgs.lib; {
          description = "Validated technical-diagram renderer CLI";
          homepage = "https://github.com/tt-a1i/archify";
          license = licenses.mit;
          mainProgram = "archify";
          platforms = platforms.all;
        };
      };

      packages.archify-skillmd = pkgs.stdenvNoCC.mkDerivation {
        inherit pname version src;

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/share"
          cp -r archify "$out/share/archify"
          substituteInPlace "$out/share/archify/SKILL.md" \
            --replace-fail "node bin/archify.mjs" "archify"
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Archify agent skill using the packaged archify CLI";
          homepage = "https://github.com/tt-a1i/archify";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
    };
}
