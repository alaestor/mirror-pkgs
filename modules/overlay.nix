{ inputs, ... }:
{
  # untested, could also try: flake.overlays.default = final: prev: let system = final.stdenv.hostPlatform.system; in self.packages.${system};
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
  perSystem = { config, pkgs, ... }: {
    overlayAttrs = config.packages;
  };
}
