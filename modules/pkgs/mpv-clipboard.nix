{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.mpv-clipboard = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "mpv-clipboard";
        version = "0-unstable-2022-11-10";

        src = pkgs.fetchFromGitHub {
          owner = "CogentRedTester";
          repo = "mpv-clipboard";
          rev = "d5cb11094da23a2153370964b65dbbc44c3058df";
          hash = "sha256-426WEPd/hfvngAIzNuQOLhcXgpP5ekX7EmtlFCbHhAM=";
          sparseCheckout = [ "clipboard.lua" ];
        };

        dontBuild = true;
        dontUnpack = true;

        installPhase = "install -Dm444 ${src}/clipboard.lua $out/share/mpv/scripts/clipboard.lua";

        passthru = {
          scriptName = "clipboard.lua";
        };

        meta = with pkgs.lib; {
          description = "Provides generic but powerful low-level clipboard commands for users and script writers.";
          homepage = "https://github.com/CogentRedTester/mpv-clipboard";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
    };
}
