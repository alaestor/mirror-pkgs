{
  config,
  lib,
  fetchFromGitea,
  ...
}:
{

  options = {

    flake.lib = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
    };

  };

  config.flake._module.args.fetchFromCodeberg = config.self.lib.fetchFromCodeberg;

  config.flake.lib = {

    fetchFromCodeberg = lib.makeOverridable (
      args: fetchFromGitea ({ domain = "codeberg.org"; } // args)
    );

    /*
      Build a derivation for a single-file mpv script fetched from GitHub.

      Type: mkMpvScript :: pkgs -> AttrSet -> Derivation

      Parameters:
        - pname, version, src: standard fetcher args
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
        src,
        scriptName,
        meta,
        updater,
        dependencies ? [ ],
        ...
      }:
      pkgs.stdenvNoCC.mkDerivation rec {
        inherit pname version src;

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
