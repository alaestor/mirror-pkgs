{ config, ... }:
{
  perSystem = { pkgs, self', fetchFromCodeberg, ... }: {
    packages.mpv-copyPasteTime = config.flake.lib.mkMpvScript pkgs {
      pname = "mpv-copyPasteTime";
      version = "0.1.0";
      src = fetchFromCodeberg {
        owner = "alaestor";
        repo = "mpv-copyPasteTime";
        rev = "v0.1.0";
        hash = "sha256-1hEj20z0/NVP3tSd4bBGCmC3O2eVIhUJWGJ5+lphx08=";
        sparseCheckout = [ "copyPasteTime.lua" ];
      };
      scriptName = "copyPasteTime.lua";
      updater = pkgs.gitUpdater {
        rev-prefix = "v";
        url = "https://codeberg.org/alaestor/mpv-copyPasteTime.git";
      };
      # Requires mpv-clipboard for its clipboard integration.
      dependencies = [
        self'.packages.mpv-clipboard
      ];
      meta = with pkgs.lib; {
        description = "Copy the current time or estimated frame number of the video to clipboard. Paste a time from the clipboard to seek to it.";
        homepage = "https://codeberg.org/alaestor/mpv-copyPasteTime";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
    };
  };
}
