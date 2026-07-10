{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.SSimSuperRes = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "SSimSuperRes";
      version = "0-unstable-2022-02-07";

      src = pkgs.fetchgit {
        url = "https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b.git";
        rev = "15d93440d0a24fc4b8770070be6a9fa2af6f200b";
        hash = "sha256-aivMV1UypnkkdmFhurxVYBp76VlY8S29hQN4EEnJRPY=";
      };

      passthru.updateScript = [
        (pkgs.lib.getExe (
          pkgs.writeShellApplication {
            name = "update";
            runtimeInputs = [
              pkgs.git
              pkgs.jq
              pkgs.nix-prefetch-git
            ];
            text = ''
              set -euo pipefail

              repo="https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b.git"

              # nix-update invokes this script from the flake repo root with
              # UPDATE_NIX_PNAME set but no file path, and this is a flake-parts
              # tree (no default.nix), so locate the definition by pname.
              file="$(git -C "$PWD" grep -l "pname = \"$UPDATE_NIX_PNAME\"" -- '*.nix' | head -n1)"
              if [[ -z "$file" ]]; then
                echo "error: could not locate definition for $UPDATE_NIX_PNAME" >&2
                exit 1
              fi
              file="$PWD/$file"

              rev="$(git ls-remote "$repo" HEAD | cut -f1)"
              echo "Updating $UPDATE_NIX_PNAME to rev $rev"

              sed -i "s|rev = \"[^\"]*\"|rev = \"$rev\"|" "$file"

              prefetch_out="$(nix-prefetch-git --url "$repo" --rev "$rev")"
              hash="$(echo "$prefetch_out" | jq -r .hash)"
              sed -i "s|hash = \"[^\"]*\"|hash = \"$hash\"|" "$file"

              date="$(echo "$prefetch_out" | jq -r .date)"
              # date is ISO-8601 like "2022-02-07T13:22:15+00:00" — extract YYYY-MM-DD
              date_ymd="''${date%%T*}"
              sed -i "s|version = \"[^\"]*\"|version = \"0-unstable-$date_ymd\"|" "$file"
            '';
          }
        ))
      ];

      dontBuild = true;
      dontUnpack = true;

      installPhase = "install -Dm444 ${src}/SSimSuperRes.glsl $out/share/shaders/SSimSuperRes.glsl";

      meta = with pkgs.lib; {
        description = "igv's sharpener + antiringing.";
        homepage = "https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
