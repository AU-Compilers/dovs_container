# Changelog

## 2026

- OCaml 5.3.0 → 5.5.0, in a switch named `dovs` rather than named after the
  compiler version.
- The toolchain is set in the image environment. It was previously reachable
  only from a login shell, so `docker exec`, a devcontainer `postCreateCommand`
  and VS Code tasks all saw no OCaml.
- The build fails if the toolchain is not reachable from a non-login shell.
- The opam repository is pinned to a commit, so a rebuild mid-semester resolves
  the same versions students got in September.
- `DEBIAN_FRONTEND`, `OPAMYES` and `OPAMROOTISOK` are build-time only. `OPAMYES`
  previously leaked into the student's shell and auto-confirmed their own
  `opam install`, removals included.
- Removed `ocamlformat-rpc`, withdrawn upstream and installing as an empty stub
  on any OCaml 5, and `stdio`, which nothing uses.
- Added `alcotest` and `ounit2`, both named in the week 40 exercise, and `num`.
- Removed `dovs.opam`. It did not parse, and nothing installed from it.
- CI: current action versions, buildx layer cache, a `:2026` tag, and the seven
  trigger branches that do not exist dropped.

## 2025

- OCaml 5.2.0 → 5.3.0, opam 2.2.0 → 2.4.1.
- Added `yojson`, `ppx_yojson_conv`, `printbox`, `printbox-text`, `cmdliner`.
- Added the `dolphin-serialize` binary.

## 2024

- Ubuntu 22.04 → 24.04.
- OCaml 5.0.0 → 5.2.0, opam 2.1.5 → 2.2.0.
