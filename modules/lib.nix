{
  lib,
  ...
}:
{

  options = {

    flake.lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };

  };

  config.flake.lib = {

    /*
      Build a derivation for a single-file mpv script fetched from GitHub.

      Type: mkMpvScript :: pkgs -> AttrSet -> Derivation

      Parameters:
        - pname, version, owner, repo, rev, hash: standard fetcher args
        - sparseCheckout: list of paths for sparse checkout (should include the script file)
        - scriptName: filename of the script (e.g. "clipboard.lua")
        - meta: standard meta attrset
        - updater: passthru updateScript (unstableGitUpdater or gitUpdater)
        - dependencies (optional): list of derivations this script depends on at runtime.
          Exposed via passthru for discoverability.
    */
    mkMpvScript =
      pkgs:
      {
        pname,
        version,
        owner,
        repo,
        rev,
        hash,
        sparseCheckout,
        scriptName,
        meta,
        updater,
        dependencies ? [ ],
        ...
      }:
      pkgs.stdenvNoCC.mkDerivation rec {
        inherit pname version;

        src = pkgs.fetchFromGitHub {
          inherit
            owner
            repo
            rev
            hash
            sparseCheckout
            ;
        };

        dontBuild = true;
        dontUnpack = true;

        installPhase = "install -Dm444 ${src + "/${scriptName}"} $out/share/mpv/scripts/${scriptName}";

        passthru = {
          inherit scriptName dependencies;
          updateScript = updater;
        };

        inherit meta;
      };

  };
}
