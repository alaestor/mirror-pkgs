{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      ghostty-shaders = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "ghostty-shaders";
        version = "0-unstable-2026-01-24";
        src = pkgs.fetchFromGitHub {
          owner = "0xhckr";
          repo = pname;
          rev = "aa6121ba2ddd5251ac75b92729c758fe41256e55";
          hash = "sha256-sg5E+OOQBgymzhC5/eJ6+jo8Fv5t2iBW9tQxlcz1K+k=";
          sparseCheckout = [ "*.glsl" ];
        };
        dontBuild = true;
        dontUnpack = true;
        installPhase = "cp -r ${src} $out";
        passthru.updateScript = pkgs.unstableGitUpdater { };

        meta = with pkgs.lib; {
          description = "A repository containing many free shaders to use with the ghostty terminal.";
          homepage = "https://github.com/0xhckr/ghostty-shaders";
          platforms = platforms.all;
        };
      };
    in
    {
      packages.ghostty-shaders = ghostty-shaders;
    };
}
