{ config, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.mpv-cycleCommands = config.flake.lib.mkMpvScript pkgs {
      pname = "mpv-cycleCommands";
      version = "0-unstable-2025-07-18";
      src = pkgs.fetchFromGitHub {
        owner = "CogentRedTester";
        repo = "mpv-scripts";
        rev = "1ed52e31543cd838d827e724910aa261ee5ec1f3";
        hash = "sha256-OMVRyoATn+cSEbrNeXK/YKUb2teaaNCpHj3KFLRSuNo=";
        sparseCheckout = [ "cycle-commands.lua" ];
      };
      scriptName = "cycle-commands.lua";
      updater = pkgs.unstableGitUpdater { };
      meta = with pkgs.lib; {
        description = "Cycles through a series of commands on a keypress. Each iteration of the cycle can contain as many commands as one wants. Syntax details are at the top of the file.";
        homepage = "https://github.com/CogentRedTester/mpv-scripts";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
