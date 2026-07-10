{ config, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.mpv-clipboard = config.flake.lib.mkMpvScript pkgs {
      pname = "mpv-clipboard";
      version = "0-unstable-2022-11-10";
      src = pkgs.fetchFromGitHub {
        owner = "CogentRedTester";
        repo = "mpv-clipboard";
        rev = "d5cb11094da23a2153370964b65dbbc44c3058df";
        hash = "sha256-426WEPd/hfvngAIzNuQOLhcXgpP5ekX7EmtlFCbHhAM=";
        sparseCheckout = [ "clipboard.lua" ];
      };
      scriptName = "clipboard.lua";
      updater = pkgs.unstableGitUpdater { };
      meta = with pkgs.lib; {
        description = "Provides generic but powerful low-level clipboard commands for users and script writers.";
        homepage = "https://github.com/CogentRedTester/mpv-clipboard";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
