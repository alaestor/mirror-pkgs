{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "bokuchi";
      version = "1.2.0";

      src = pkgs.fetchFromGitHub {
        owner = "Bokuchi-Editor";
        repo = "bokuchi";
        tag = "v${version}";
        hash = "sha256-lKO9I+Voyuif+M7bp17xA94x97WrxX+7Q7wSGefmC4U=";
      };
    in
    {
      packages.bokuchi = pkgs.rustPlatform.buildRustPackage {
        inherit pname version src;

        # The Rust crate lives in src-tauri/, but the npm frontend that
        # `beforeBuildCommand` builds lives at the repo root, so the build
        # runs from the root and the tauri hook is pointed at src-tauri/.
        cargoRoot = "src-tauri";
        buildAndTestSubdir = "src-tauri";
        cargoHash = "sha256-6BimgDg+6pLWLCxkWuux/9cwbmNBdtST4ktwWumtqr4=";

        npmDeps = pkgs.fetchNpmDeps {
          inherit src;
          name = "${pname}-${version}-npm-deps";
          fetcherVersion = 2;
          hash = "sha256-dZ6SpapQKinajDnQbltM8Qc9YYzQjMZnnChUYTy+w8Y=";
        };

        # The upstream config emits Tauri updater artifacts, which abort the
        # build unless TAURI_SIGNING_PRIVATE_KEY is set. Self-updating is
        # meaningless for a Nix-managed install anyway.
        postPatch = ''
          substituteInPlace src-tauri/tauri.conf.json \
            --replace-fail '"createUpdaterArtifacts": true,' ""
        '';

        nativeBuildInputs = [
          pkgs.cargo-tauri.hook
          pkgs.nodejs
          pkgs.npmHooks.npmConfigHook
          pkgs.pkg-config
          pkgs.wrapGAppsHook3
        ];

        buildInputs = [
          pkgs.glib-networking
          pkgs.openssl
          pkgs.webkitgtk_4_1
        ];

        # Enumerates fonts from the standard system directories, which don't
        # exist inside the build sandbox.
        checkFlags = [ "--skip=tests::test_list_system_fonts_returns_usable_families" ];

        # Only the Linux desktop bundle is useful from Nix; the default
        # "all" target additionally builds AppImage/deb, which need network
        # access and bundled runtimes.
        tauriBuildFlags = [
          "--bundles"
          "deb"
        ];

        meta = with lib; {
          description = "Lightweight Markdown editor with variable substitution";
          homepage = "https://github.com/Bokuchi-Editor/bokuchi";
          license = licenses.mit;
          mainProgram = "bokuchi";
          platforms = platforms.linux;
        };
      };
    };
}
