{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # Available as a perSystem module arg: `{ fetchFromCodeberg, ... }:`
      _module.args.fetchFromCodeberg = lib.makeOverridable (
        args: pkgs.fetchFromGitea ({ domain = "codeberg.org"; } // args)
      );
    };
}
