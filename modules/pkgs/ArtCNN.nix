{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.ArtCNN = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "ArtCNN";
      version = "1.6.2";

      src = pkgs.fetchFromGitHub {
        owner = "Artoriuz";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-S1CimvDxjBr0TLeCq9791dPq22bwiecRQe3IagKlGjg=";
        sparseCheckout = [ "GLSL/" ];
      };

      dontBuild = true;
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/share/${pname}
        cp -r ${src + "/GLSL"} $out/share/${pname}
      '';

      meta = with pkgs.lib; {
        description = "A collection of simple SISR CNNs aimed at anime content";
        homepage = "https://github.com/Artoriuz/ArtCNN";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
