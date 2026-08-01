# Serena packaging

This package consumes Serena's pinned upstream flake and wraps its executable
with language servers supplied by nixpkgs.

## solidlsp dependency handling

solidlsp mixes two dependency models. Some providers prefer an executable from
`PATH`, while others unconditionally populate Serena's writable
language-server cache through npm or direct downloads. The local patches add
`PATH`-first resolution for:

- Bash Language Server and ShellCheck
- JSON Language Server
- YAML Language Server
- Marksman

Serena already supports finding `nixd` on `PATH`, so it only needs to be added
to the wrapper.

Each backend has a separate patch so it can be reviewed, updated, or removed
independently when changing the pinned Serena revision.

## Future candidates

Other straightforward `PATH`-first candidates found during the audit include:

- Ansible Language Server
- Intelephense
- Some Sass Language Server
- VS Code HTML Language Server
- VTSLS
- Clojure LSP
- CUE
- Texlab
- Terraform LS
- Dart
- FsAutoComplete

TypeScript, Svelte, Vue, Angular, and Solidity are deferred. Their providers
coordinate multiple executables, SDKs, plugins, or companion tools, so replacing
their managed installation requires more than a single executable lookup.

Several other providers already prefer system executables, including clangd,
rust-analyzer, nixd, lua-language-server, Taplo, luau-lsp, ccls, Haxe, Elm,
Metals, and Ruby LSP.

## Updating

After changing the Serena input revision:

1. Build `.#serena` to ensure the upstream uv2nix environment still compiles.
2. Confirm every local patch still applies.
3. Exercise each patched dependency provider and verify it resolves the
   nixpkgs executable rather than entering its managed-install fallback.
4. Run `nix flake check`.
