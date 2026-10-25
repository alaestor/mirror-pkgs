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
      version = "0-unstable-2026-10-19";
      src = pkgs.fetchFromGitHub {
        owner = "andrewrabert";
        repo = "jellium-desktop";
        rev = "1b73a13b32e427c27815dac48b0bd82de771f454";
        fetchSubmodules = true;
        hash = "sha256-qawW4q4wztT294+gEWXuaVes4UM7yC0DFi+o3vKqPiw=";
      };

      cefArchive = pkgs.fetchzip {
        url = "https://cef-builds.spotifycdn.com/cef_binary_152.0.8+g1ce985c+chromium-152.0.7977.134_linux64_minimal.tar.bz2";
        hash = "sha256-djoHb9jRWG+RPNkW/0oaYPf+4ReaI7kXzPL1HKfJNh0=";
        stripRoot = true;
      };

      cef = pkgs.runCommand "jellium-cef-152.0.8" { } ''
        sdk=${cefArchive}
        mkdir $out
        ln -s $sdk/Release/* $out
        ln -s $sdk/Resources/* $out
        ln -s $sdk/include $out/include
        ln -s $sdk/cmake $out/cmake
        ln -s $sdk/libcef_dll $out/libcef_dll
        cat >$out/archive.json <<'EOF'
        {"type":"minimal","name":"cef_binary_152.0.8+g1ce985c+chromium-152.0.7977.134_linux64_minimal","sha1":"25798f5f87b9cc699311c9abae73f4ef0f56ea76"}
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
        alsa-lib
        at-spi2-atk
        atk
        cairo
        cups
        dbus
        expat
        glib
        libGL
        libgbm
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxkbcommon
        libxrandr
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
        cargoHash = "sha256-RuF7Jb/7Xy/iaHdzaaNUksvdZutE6E89Gb2Mn1Af+6k=";
        cargoBuildFlags = [ "--bin" "jellium-desktop" ];
        # Workspace tests try to execute CEF-linked binaries before CEF's
        # runtime library closure is wrapped; the upstream Nix flakes skip them too.
        doCheck = false;

        nativeBuildInputs = [
          pkgs.python3
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

        # Validate the actual vendored bindings even with GUI tests disabled.
        preBuild = ''
          LD_LIBRARY_PATH="${lib.makeLibraryPath cefRuntimeLibraries}:$LD_LIBRARY_PATH" python3 <<'PYCEF'
          import ctypes
          import json
          import pathlib
          import re
          import subprocess

          metadata = json.loads(subprocess.check_output([
              "cargo", "metadata", "--offline", "--locked", "--format-version", "1",
              "--manifest-path", "src/Cargo.toml",
          ]))
          package, = [p for p in metadata["packages"] if p["name"] == "cef-dll-sys"]
          bindings = (pathlib.Path(package["manifest_path"]).parent /
                      "src/bindings/x86_64_unknown_linux_gnu.rs").read_text()
          api = int(re.search(r"pub const CEF_API_VERSION_LAST: i32 = (\d+);", bindings)[1])
          required = re.search(r'pub const CEF_VERSION:.*?= b"(.*?)\\0";', bindings)[1]
          header = pathlib.Path("${cef}/include/cef_version.h").read_text()
          bundled = re.search(r'#define CEF_VERSION "(.*?)"', header)[1]
          if required != bundled:
              raise SystemExit(f"CEF SDK mismatch: bindings require {required}, bundled {bundled}")
          cef = ctypes.CDLL("${cef}/libcef.so")
          cef.cef_api_hash.argtypes = [ctypes.c_int, ctypes.c_int]
          cef.cef_api_hash.restype = ctypes.c_char_p
          actual_hash = cef.cef_api_hash(api, 0)
          if not actual_hash:
              raise SystemExit(f"Bundled libcef does not support bindings API {api}")
          hashes = pathlib.Path("${cef}/include/cef_api_versions.h").read_text()
          expected_hash = re.search(
              rf'#elif defined\(OS_LINUX\)\s+#define CEF_API_HASH_{api} "(.*?)"', hashes,
          )[1].encode()
          if actual_hash != expected_hash:
              raise SystemExit(f"Bundled libcef API {api} hash differs from SDK headers")
          print(f"CEF SDK check passed: {bundled}, API {api}")
          PYCEF
        '';

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
