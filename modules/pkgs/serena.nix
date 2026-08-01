{ inputs, ... }:

{
  flake-file.inputs.serena = {
    url = "github:oraios/serena/v1.6.1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { pkgs, system, ... }:
    let
      upstreamPackages = inputs.serena.packages.${system};
      patchedEnvironment = upstreamPackages.serena-env.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          site_packages=$out/lib/python3.11/site-packages
          chmod u+w "$site_packages"
          cp --recursive --dereference "$site_packages/solidlsp" "$site_packages/solidlsp.mutable"
          chmod --recursive u+w "$site_packages/solidlsp.mutable"
          rm "$site_packages/solidlsp"
          mv "$site_packages/solidlsp.mutable" "$site_packages/solidlsp"
          patch -d "$site_packages" -p1 < ${./serena-prefer-packaged-bash-tools.patch}
        '';
      });
      patchedSerena = upstreamPackages.serena.overrideAttrs (old: {
        preFixup = builtins.replaceStrings [
          "${upstreamPackages.serena-env}"
        ] [
          "${patchedEnvironment}"
        ] old.preFixup;
      });
    in
    {
      packages.serena = pkgs.symlinkJoin {
        name = "serena-1.6.1";
        paths = [ patchedSerena ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/serena \
            --prefix PATH : ${
              pkgs.lib.makeBinPath [
                pkgs.bash-language-server
                pkgs.nodejs
                pkgs.shellcheck
              ]
            }
        '';

        meta = upstreamPackages.serena.meta // {
          mainProgram = "serena";
        };
      };
    };
}
