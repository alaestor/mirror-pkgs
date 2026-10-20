{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      version = "2.5.5";
      src = pkgs.fetchFromGitHub {
        owner = "ChrisDKN";
        repo = "Amethyst-Mod-Manager";
        tag = "v${version}";
        hash = "sha256-8bUKZ7RsR7X6ZXnU3R1JhbQW/jObBKrjCsNwoQK9+AI=";
      };
    in
    {
      packages.amethyst-mod-manager =
        (pkgs.callPackage "${src}/nix/package.nix" {
          inherit src version;
          # Upstream's libloot bindings require Python <= 3.13.
          python3 = pkgs.python313;
          meson = pkgs.meson.override { python3 = pkgs.python313; };
        }).overrideAttrs (old: {
          # Keep nix-update's attribute positions in this repository.
          inherit src version;

          # KDE's Union style crashes during QApplication initialization.
          # Use Qt's built-in style instead of loading the desktop's plugin.
          preFixup = (old.preFixup or "") + ''
            qtWrapperArgs+=(--set QT_STYLE_OVERRIDE Fusion)
          '';
        });
    };
}
