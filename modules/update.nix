{ ... }:
{
  /**
    Bulk-update flake packages via nix-update.

    > [!note]
    > Alternatively, to target a single package, you can run:
    > `nix run nixpkgs#nix-update -- --flake mpv-cycleCommands`

    Usage:
      nix run .#update
      nix run .#update -- --verbose
      nix run .#update -- --help

    > **Implementation notes**
    >
    > - Lives in `modules/update.nix`
    > - Iterates all `self'.packages` and calls nix-update on each.
    > - Passes `--use-update-script` only for packages whose source host
    >   nix-update can't auto-detect (e.g. gist.github.com). For common
    >   hosts (GitHub, GitLab, etc.) nix-update handles detection itself.
    > - Passes `--version=branch` when the version contains `-unstable-`.
  */
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      # nix-update can auto-detect latest versions from these hosts.
      # Anything else (e.g. gist.github.com) must use passthru.updateScript.
      autoDetectableHosts = [
        "github.com"
        "gitlab.com"
        "codeberg.org"
        "crates.io"
        "pypi.org"
        "registry.npmjs.org"
        "rubygems.org"
        "download.savannah.gnu.org"
        "git.sr.ht"
        "bitbucket.org"
      ];

      scriptName = "smart-updater";

      getHost =
        url:
        builtins.head (lib.splitString "/" (lib.removePrefix "http://" (lib.removePrefix "https://" url)));

      updatePackages = builtins.filter (p: p != null) (
        lib.mapAttrsToList (
          name: pkg:
          let
            hasUpdateScript = (pkg.passthru or { }) ? updateScript && pkg.passthru.updateScript != null;
            srcUrl = pkg.src.url or "";
            isAutoDetectable = builtins.elem (getHost srcUrl) autoDetectableHosts;
            # Only pass --use-update-script for hosts nix-update can't
            # auto-detect. Scripts like gitUpdater assume a nixpkgs tree and
            # break under --use-update-script in a flake-parts layout.
            useUpdateScript = hasUpdateScript && !isAutoDetectable;
            # Skip packages with no source URL (e.g. script-only wrappers).
            canUpdate = srcUrl != "" && (isAutoDetectable || hasUpdateScript);
          in
          if canUpdate then
            {
              args = [
                "--flake"
                name
              ]
              ++ lib.optional useUpdateScript "--use-update-script"
              ++ lib.optional (lib.hasInfix "-unstable-" (lib.getVersion pkg)) "--version=branch";
            }
          else
            null
        ) self'.packages
      );

      updateApp = pkgs.writeShellApplication {
        name = scriptName;
        runtimeInputs = [
          pkgs.coreutils
          pkgs.git
          pkgs.nix
          pkgs.nix-update
        ];
        text = ''
          set -euo pipefail

          verbose=0
          while [[ $# -gt 0 ]]; do
            case "$1" in
              -v|--verbose)
                verbose=1
                shift
                ;;
              -h|--help)
                printf '%s\n' \
                  "Usage: update [options]" \
                  "" \
                  "Update all flake packages using nix-update --flake" \
                  "" \
                  "Options:" \
                  "  -v, --verbose   Show nix-update output and detailed summary" \
                  "  -h, --help      Show this help"
                exit 0
                ;;
              *)
                echo "Unknown option: $1" >&2
                echo "Try 'update --help'" >&2
                exit 1
                ;;
            esac
          done

          root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
          cd "$root"
          if [[ ! -f flake.nix ]]; then
            echo "error: must be run from the flake repository (no flake.nix in $root)" >&2
            exit 1
          fi

          updated=()
          unchanged=()
          failed=()

          update_package() {
            local name="$2"
            local before after logfile status
            local -a args=("$@")

            if [[ "$verbose" -ne 1 ]]; then
              args+=(--quiet)
            else
              echo "==> $name"
            fi

            before="$(git diff)"
            logfile="$(mktemp)"
            status=0

            if [[ "$verbose" -eq 1 ]]; then
              nix-update "''${args[@]}" || status=$?
            else
              nix-update "''${args[@]}" >"$logfile" 2>&1 || status=$?
            fi

            if [[ "$status" -eq 0 ]]; then
              after="$(git diff)"
              if [[ "$before" == "$after" ]]; then
                unchanged+=("$name")
                [[ "$verbose" -eq 1 ]] && echo "    unchanged"
              else
                updated+=("$name")
                [[ "$verbose" -eq 1 ]] && echo "    updated"
              fi
            else
              failed+=("$name")
              echo "error: failed to update $name" >&2
              [[ "$verbose" -ne 1 && -s "$logfile" ]] && cat "$logfile" >&2
            fi

            rm -f "$logfile"
            if [[ "$verbose" -eq 1 ]]; then
              echo
            fi
          }

          # Commands and their arguments are generated at evaluation time.
          ${lib.concatMapStrings (p: "update_package ${lib.escapeShellArgs p.args}\n") updatePackages}

          # Summary
          if [[ "$verbose" -eq 1 ]]; then
            echo "Updated: ''${#updated[@]}"
            [[ "''${#updated[@]}" -gt 0 ]] && printf '  %s\n' "''${updated[@]}"
            echo
            echo "Unchanged: ''${#unchanged[@]}"
            [[ "''${#unchanged[@]}" -gt 0 ]] && printf '  %s\n' "''${unchanged[@]}"
            [[ "''${#failed[@]}" -gt 0 ]] && echo && echo "Failed: ''${#failed[@]}" && printf '  %s\n' "''${failed[@]}"
          else
            echo "updated: ''${#updated[@]}"
            echo "unchanged: ''${#unchanged[@]}"
            [[ "''${#failed[@]}" -gt 0 ]] && echo "failed: ''${#failed[@]}"
          fi

          [[ "''${#failed[@]}" -gt 0 ]] && exit 1
        '';
      };
    in
    {
      apps.update = {
        type = "app";
        program = "${updateApp}/bin/${scriptName}";
        meta.description = "Intelligently try to run `nix-update` for every package in outputs.";
      };
    };
}
