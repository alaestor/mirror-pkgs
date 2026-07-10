{ ... }:
{
  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    let
      pname = "helium-browser";
      version = "0.13.4.1";

      sources = {
        x86_64-linux = {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
          hash = "sha256-z23up+T6bj6F+cQslmI92bEksIAw1OQHRIrmQSaaxY8=";
        };
      };

      src = pkgs.fetchurl {
        inherit (sources.${system} or (throw "Unsupported system: ${system}")) url hash;
      };

      meta = {
        description = "The Chromium-based web browser made for people, with love. Best privacy by default, unbiased ad-blocking, no bloat and no noise.";
        homepage = "https://helium.computer/";
        mainProgram = "helium";
        license = pkgs.lib.licenses.gpl3;
        platforms = builtins.attrNames sources;
      };
    in
    {
      packages.helium-browser =
        lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux pkgs.appimageTools.wrapType2
          {
            inherit
              pname
              version
              src
              meta
              ;
          };
    };
}
