{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "headroom-ai";
      version = "0.37.0-unstable-2026-08-30";

      src = pkgs.fetchFromGitHub {
        owner = "headroomlabs-ai";
        repo = "headroom";
        rev = "65477f933a775bd519d4b037d31d93b3e255e297";
        hash = "sha256-zgSubjkNM5cpKnyQxx+9bF0BmiX7xvxXqzN39MMrGJY=";
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
          "--prefix"
          "PATH"
          ":"
          (pkgs.lib.makeBinPath [
            pkgs.ast-grep
            pkgs.nodejs
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
