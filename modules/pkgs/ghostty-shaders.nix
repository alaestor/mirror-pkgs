{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.ghostty-shaders = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "ghostty-shaders";
        version = "0-unstable-2026-06-12";

        src = pkgs.fetchFromGitHub {
          owner = "0xhckr";
          repo = "ghostty-shaders";
          rev = "a42f7b637769b90a1c9cd55f170c6d912ba5b8a0";
          hash = "sha256-puUfnTOzU6aezj7KvB7uW2ZDC6ZLHaVevwJmHeqsrO8=";
          sparseCheckout = [ "*.glsl" ];
        };

        dontBuild = true;
        dontUnpack = true;

        installPhase = "cp -r ${src} $out";

        meta = with pkgs.lib; {
          description = "A repository containing many free shaders to use with the ghostty terminal.";
          homepage = "https://github.com/0xhckr/ghostty-shaders";
          platforms = platforms.all;
        };
      };
    };
}
