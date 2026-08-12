{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.ghostty-shaders = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "ghostty-shaders";
        version = "0-unstable-2026-07-13";

        src = pkgs.fetchFromGitHub {
          owner = "0xhckr";
          repo = "ghostty-shaders";
          rev = "85898f08fcf4a9274e418912098e99e00a5f8350";
          hash = "sha256-EEWa5RaXhjsQT6eZhA+12ohnpyd8nCJnVUUdHlGU97U=";
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
