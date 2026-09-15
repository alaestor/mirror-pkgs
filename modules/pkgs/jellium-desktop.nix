/**
  Jellium Desktop: an unofficial Jellyfin client built on CEF and mpv.

  The upstream project has no versioned releases.  Pin the revision and its
  CEF SDK explicitly so updates remain reproducible.
*/
{ ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      version = "0.1.0-dev-2026-08-09";
      src = pkgs.fetchFromGitHub {
        owner = "andrewrabert";
        repo = "jellium-desktop";
        rev = "28f2cf16a1f1b819884dd6a72919ca55bdf9bd73";
        fetchSubmodules = true;
        hash = "sha256-cs7wxsX5fHaxVvnsSKjbq+rG//LjkV7592LnThnlPJE=";
      };

      cefArchive = pkgs.fetchzip {
        url = "https://cef-builds.spotifycdn.com/cef_binary_151.3.16+gbe1e15d+chromium-151.0.7922.109_linux64_minimal.tar.bz2";
        hash = "sha256-UJWYYHh+hEFyn0CbYYY24t0wZmheAtnwwEFheIKcdnM=";
        stripRoot = false;
      };

      cef = pkgs.runCommand "jellium-cef-151.3.16" { } ''
        sdk=${cefArchive}/cef_binary_151.3.16+gbe1e15d+chromium-151.0.7922.109_linux64_minimal
        mkdir $out
        ln -s $sdk/Release/* $out
        ln -s $sdk/Resources/* $out
        ln -s $sdk/include $out/include
        ln -s $sdk/cmake $out/cmake
        ln -s $sdk/libcef_dll $out/libcef_dll
        cat >$out/archive.json <<'EOF'
        {"type":"minimal","name":"cef_binary_151.3.16+gbe1e15d+chromium-151.0.7922.109_linux64_minimal","sha1":"13042a73aeaf0e853a719d3ddad0751514665bb9"}
        EOF
      '';

      jelliumMpv = pkgs.mpv-unwrapped.overrideAttrs (old: {
        inherit version;
        src = "${src}/third_party/mpv";
        outputs = [ "out" ];
        patches = [ ];
        postPatch = ''
          patchShebangs TOOLS
        '';
        dontVersionCheck = true;
      });

      cefRuntimeLibraries = with pkgs; [
        at-spi2-atk
        atk
        cairo
        cups
        dbus
        expat
        glib
        libGL
        libxcomposite
        libxdamage
        nspr
        nss
        pango
        systemd
      ];
    in
    {
      packages.jellium-desktop = pkgs.rustPlatform.buildRustPackage {
        pname = "jellium-desktop";
        inherit version src;

        cargoRoot = "src";
        buildAndTestSubdir = "src";
        cargoHash = "sha256-JFFQjOw4Iu6NiQScQqYg/J7XEkLbHCDa+XS12VJJdVI=";
        cargoBuildFlags = [ "--bin" "jellium-desktop" ];
        # Workspace tests try to execute CEF-linked binaries before CEF's
        # runtime library closure is wrapped; the upstream Nix flakes skip them too.
        doCheck = false;

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.pkg-config
          pkgs.rustPlatform.bindgenHook
        ];
        buildInputs = [
          pkgs.ffmpeg
          jelliumMpv
          pkgs.libxcb
          pkgs.libxkbcommon
        ];

        CEF_PATH = cef;
        CEF_RESOURCES_DIR = "${cef}";
        JFN_MPV_INCLUDE_DIR = "${src}/third_party/mpv/include";
        JFN_MPV_LIB_DIR = "${jelliumMpv}/lib";
        JFN_GIT_HASH = "28f2cf1";
        JFN_GIT_DIRTY = "0";
        NIX_LDFLAGS = "--allow-shlib-undefined";

        postInstall = ''
          install -Dm755 \
            target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/jellium-desktop \
            $out/libexec/jellium-desktop/jellium-desktop
          cp -a ${cef}/. $out/libexec/jellium-desktop/
          install -Dm644 resources/linux/net.nullsum.JelliumDesktop.desktop \
            $out/share/applications/net.nullsum.JelliumDesktop.desktop
          install -Dm644 resources/linux/net.nullsum.JelliumDesktop.metainfo.xml \
            $out/share/metainfo/net.nullsum.JelliumDesktop.metainfo.xml
          install -Dm644 resources/linux/net.nullsum.JelliumDesktop.svg \
            $out/share/icons/hicolor/scalable/apps/net.nullsum.JelliumDesktop.svg
          makeWrapper $out/libexec/jellium-desktop/jellium-desktop $out/bin/jellium-desktop \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath cefRuntimeLibraries}"
        '';

        meta = {
          description = "Unofficial Jellyfin desktop client built on CEF and mpv";
          homepage = "https://github.com/andrewrabert/jellium-desktop";
          license = lib.licenses.gpl2Plus;
          mainProgram = "jellium-desktop";
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
