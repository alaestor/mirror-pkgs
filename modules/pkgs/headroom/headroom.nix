{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "headroom-ai";
      version = "0.32.0-unstable-2026-07-22";

      src = pkgs.fetchFromGitHub {
        owner = "headroomlabs-ai";
        repo = "headroom";
        rev = "806d2e468ace012ebfa1a0907a679781b5004c72";
        hash = "sha256-RgNYTcT0iOfYwM6KJEefzVbvbaKjXveuBFU+nVTw0GY=";
      };

      python = pkgs.python313;
      pythonPackages = python.pkgs;
      runtimeDependencies = with pythonPackages; [
        click
        fastapi
        h2
        httpx
        litellm
        magika
        mcp
        onnxruntime
        openai
        opentelemetry-api
        orjson
        pydantic
        pyyaml
        rich
        sqlite-vec
        tiktoken
        tomlkit
        transformers
        uvicorn
        watchdog
        websockets
        zstandard
      ];
    in
    {
      packages.headroom = pythonPackages.buildPythonPackage {
        inherit pname version src;
        pyproject = true;

        # "Good enough" local lean-ctx integration: force its prebuilt static
        # musl release instead of packaging it, and let `init --agent codex`
        # run in the repository so its output survives. The tradeoff is a
        # runtime download plus extra project-local integration files for
        # other agents (.claude/, .cursorrules, AGENTS.md, and LEAN-CTX.md).
        patches = [
          ./headroom-lean-ctx.patch
          ./headroom-serena-config.patch
        ];

        cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = "${src}/Cargo.lock";
        };

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.rustPlatform.cargoSetupHook
          pkgs.rustPlatform.maturinBuildHook
        ];

        dependencies = runtimeDependencies;

        # ast-grep is distributed as a Python wheel upstream, but Nixpkgs
        # packages the same CLI as a native executable.
        pythonRemoveDeps = [ "ast-grep-cli" ];

        # Headroom launches long-lived helpers with
        # `sys.executable -m headroom...`. Export the complete module path so
        # those bare Python subprocesses inherit the same environment as the
        # generated `headroom` entrypoint.
        makeWrapperArgs = [
          "--set-default"
          "HEADROOM_LEAN_CTX_TARGET"
          "x86_64-unknown-linux-musl"
          "--prefix"
          "PATH"
          ":"
          (pkgs.lib.makeBinPath [
            pkgs.ast-grep
            pkgs.rtk
            pkgs.uv
          ])
          "--prefix"
          "PYTHONPATH"
          ":"
          (pythonPackages.makePythonPath runtimeDependencies)
          "--prefix"
          "PYTHONPATH"
          ":"
          "$out/${python.sitePackages}"
        ];

        doCheck = false;

        pythonImportsCheck = [
          "headroom"
          "headroom._core"
        ];

        passthru.updateScript = pkgs.nix-update-script {
          extraArgs = [ "--version=branch" ];
        };

        meta = with pkgs.lib; {
          description = "Context optimization layer for LLM applications";
          homepage = "https://github.com/headroomlabs-ai/headroom";
          changelog = "https://github.com/headroomlabs-ai/headroom/blob/${src.rev}/CHANGELOG.md";
          license = licenses.asl20;
          mainProgram = "headroom";
          platforms = platforms.unix;
        };
      };
    };
}
