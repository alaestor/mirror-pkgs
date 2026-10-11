{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "harling";
      version = "0.3.2";
      src = pkgs.fetchurl {
        url = "https://download.playharling.com/Harling-${version}.AppImage";
        hash = "sha256-N/7hxuGThvHj2AmeN5eNc+WGwu758DrlHeB2TXXtZso=";
      };
      appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
    in
    {
      packages.harling = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraInstallCommands = ''
          install -Dm644 ${appimageContents}/harling.desktop $out/share/applications/harling.desktop
          substituteInPlace $out/share/applications/harling.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=harling'
          mkdir -p $out/share/icons
          cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/
        '';

        meta = {
          description = "Launcher for the Harling online role-playing game";
          homepage = "https://playharling.com/";
          license = lib.licenses.unfree;
          mainProgram = "harling";
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
