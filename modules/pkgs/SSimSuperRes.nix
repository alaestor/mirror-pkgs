{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.SSimSuperRes = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "SSimSuperRes";
      version = "0-unstable-2022-02-07";

      src = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b/raw/15d93440d0a24fc4b8770070be6a9fa2af6f200b/SSimSuperRes.glsl";
        sha256 = "sha256-qLJxFYQMYARSUEEbN14BiAACFyWK13butRckyXgVRg8=";
      };

      dontBuild = true;
      dontUnpack = true;

      installPhase = "install -Dm444 ${src} $out/share/shaders/SSimSuperRes.glsl";

      meta = with pkgs.lib; {
        description = "igv's sharpener + antiringing.";
        homepage = "https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
