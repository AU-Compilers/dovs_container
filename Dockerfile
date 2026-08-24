# check=skip=FromPlatformFlagConstDisallowed
# The platform is fixed: the toolchain emits x86-64 assembly and runs it.
FROM --platform=linux/x86-64 ubuntu:24.04

# ARG, not ENV: a leaked OPAMYES auto-confirms every later `opam install` in
# the image, removals included.
ARG DEBIAN_FRONTEND=noninteractive
ARG OPAMYES=true
ARG OPAMROOTISOK=true

ARG OCAML_VERSION=5.5.0
ARG OPAM_SWITCH=dovs

# Pinned so that a rebuild in November resolves what September resolved.
ARG OPAM_REPO_COMMIT=e294804227880414b52e781d7f705e19f7d8dced

RUN apt-get update && apt-get -y upgrade && apt-get -y install \
    unzip \
    zip \
    make \
    gcc \
    m4 \
    rlwrap \
    clang \
    curl \
    lldb \
    patch \
    git \
    bzip2 \
    wget \
    graphviz \
    tree

RUN curl -sL https://github.com/ocaml/opam/releases/download/2.4.1/opam-2.4.1-x86_64-linux -o opam \
    && install opam /usr/local/bin/opam \
    && opam init --disable-sandboxing -a -y --bare \
    && opam repository set-url default "git+https://github.com/ocaml/opam-repository#${OPAM_REPO_COMMIT}" \
    && opam update

RUN opam switch create "${OPAM_SWITCH}" "ocaml-base-compiler.${OCAML_VERSION}"
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# opam's own hook goes in ~/.profile, which only a login bash reads, so
# `docker exec`, a devcontainer postCreateCommand and VS Code tasks see no
# OCaml. The image Env is inherited by every process instead.
ENV OPAM_SWITCH_PREFIX=/root/.opam/dovs \
    PATH=/root/.opam/dovs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    CAML_LD_LIBRARY_PATH=/root/.opam/dovs/lib/stublibs:/root/.opam/dovs/lib/ocaml/stublibs:/root/.opam/dovs/lib/ocaml \
    OCAML_TOPLEVEL_PATH=/root/.opam/dovs/lib/toplevel

# Login shells get the same environment from opam, so the two cannot drift.
RUN opam env --switch="${OPAM_SWITCH}" --set-switch > /etc/profile.d/opam.sh

RUN opam install dune menhir merlin fmt utop ocaml-lsp-server ocamlformat yojson ppx_yojson_conv \
      alcotest ounit2 num \
      printbox printbox-text cmdliner && \
    opam user-setup install

# Under a non-login, non-interactive shell: if PATH is wrong the build fails
# here rather than the semester.
RUN sh -c 'dune --version && ocamlformat --version && ocamllsp --version && ocamlmerlin -version'

# The URL is fixed, so a re-upload does not invalidate this layer. Bump the
# date to the day it was re-uploaded to force the refetch.
ARG DOLPHIN_SERIALIZE_REV=2025-08-04
RUN echo "dolphin-serialize revision ${DOLPHIN_SERIALIZE_REV}" && \
    wget -q 'https://cs.au.dk/~timany/dolphin-serializer/dolphinSerializer.exe' \
      -O /usr/local/bin/dolphin-serialize && \
    chmod +x /usr/local/bin/dolphin-serialize
