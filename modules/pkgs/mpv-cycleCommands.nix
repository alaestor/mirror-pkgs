{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.mpv-cycleCommands = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "mpv-cycleCommands";
        version = "0-unstable-2026-01-10";

        src = pkgs.fetchFromGitHub {
          owner = "CogentRedTester";
          repo = "mpv-scripts";
          rev = "cdfbd28f86f269551ce893357fdd3962f7551d07";
          hash = "sha256-dt8fHkrS6Guh4cAqvoanJgRc29p22iCJct1yzZuGr3A=";
          sparseCheckout = [ "cycle-commands.lua" ];
        };

        dontBuild = true;
        dontUnpack = true;

        installPhase = "install -Dm444 ${src}/cycle-commands.lua $out/share/mpv/scripts/cycle-commands.lua";

        passthru = {
          scriptName = "cycle-commands.lua";
        };

        meta = with pkgs.lib; {
          description = "Cycles through a series of commands on a keypress. Each iteration of the cycle can contain as many commands as one wants. Syntax details are at the top of the file.";
          homepage = "https://github.com/CogentRedTester/mpv-scripts";
          license = licenses.mit;
          platforms = platforms.all;
        };
      };
    };
}
