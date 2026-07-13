{ inputs, ... }:
{

  imports = [ inputs.flake-parts.flakeModules.modules ];

  # Exposed as `inputs.<this-flake>.modules.fetchers.codeberg`
  flake.modules.fetchers.codeberg = { lib, ... }: {
    perSystem = { pkgs, ... }: {
      _module.args.fetchFromCodeberg = lib.makeOverridable (
        args: pkgs.fetchFromGitea ({ domain = "codeberg.org"; } // args)
      );
    };
  };

  # Self-use: define the same module inline so it's available in this flake's perSystem
  perSystem = { lib, pkgs, ... }: {
    _module.args.fetchFromCodeberg = lib.makeOverridable (
      args: pkgs.fetchFromGitea ({ domain = "codeberg.org"; } // args)
    );
  };

}
