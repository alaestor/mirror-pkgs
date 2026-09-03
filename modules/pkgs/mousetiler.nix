{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.mousetiler = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "mousetiler";
        version = "6.5.0";

        src = pkgs.fetchFromGitHub {
          owner = "rxappdev";
          repo = "MouseTiler";
          rev = "v${version}";
          hash = "sha256-jgtNOu98Z8iDTo5zNvPmGkgP1eGLkKL510DpZZ9xyvA=";
        };

        dontBuild = true;
        dontConfigure = true;

        # `src/` is the KPackage root itself (metadata.json + contents/),
        # ready to drop straight into ~/.local/share/kwin/scripts/mousetiler
        # (metadata.json's `KPlugin.Id` is "mousetiler") without going
        # through kpackagetool6 — that's how KWin scripts are traditionally
        # installed by hand, and it's all a script (as opposed to a full
        # KPackage app) needs.
        installPhase = "cp -r src $out";

        meta = with pkgs.lib; {
          description = "KWin script: tile windows by moving the mouse a few pixels";
          homepage = "https://github.com/rxappdev/MouseTiler";
          license = licenses.gpl3Only;
          platforms = platforms.linux;
        };
      };
    };
}
