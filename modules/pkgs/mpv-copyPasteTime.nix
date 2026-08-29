{ ... }:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.mpv-copyPasteTime = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "mpv-copyPasteTime";
        version = "0.1.0";

        src = pkgs.fetchgit {
          url = "https://git.0x04.cc/alaestor/mpv-copyPasteTime";
          rev = "v${version}";
          hash = "sha256-1hEj20z0/NVP3tSd4bBGCmC3O2eVIhUJWGJ5+lphx08=";
          sparseCheckout = [ "copyPasteTime.lua" ];
        };

        dontBuild = true;
        dontUnpack = true;

        installPhase = "install -Dm444 ${src}/copyPasteTime.lua $out/share/mpv/scripts/copyPasteTime.lua";

        passthru = {
          scriptName = "copyPasteTime.lua";
          # Requires mpv-clipboard for its clipboard integration.
          dependencies = [
            self'.packages.mpv-clipboard
          ];
        };

        meta = with pkgs.lib; {
          description = "Copy the current time or estimated frame number of the video to clipboard. Paste a time from the clipboard to seek to it.";
          homepage = "https://git.0x04.cc/alaestor/mpv-copyPasteTime";
          license = licenses.gpl3;
          platforms = platforms.all;
        };
      };
    };
}
