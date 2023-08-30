FROM --platform=linux/x86-64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
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
    wget


# RUN wget -O ~/vsls-reqs https://aka.ms/vsls-linux-prereq-script && chmod +x ~/vsls-reqs && ~/vsls-reqs

ENV OPAMYES=true OPAMROOTISOK=true
RUN curl -sL https://github.com/ocaml/opam/releases/download/2.1.5/opam-2.1.5-x86_64-linux -o opam \
    && install opam /usr/local/bin/opam \
    && opam init --disable-sandboxing -a -y --bare \
    && opam update

RUN opam switch create 5.0.0
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install these dependencies early to increase intermediate image reuse
COPY ./dovs.opam* .

RUN opam install dune stdio menhir merlin fmt utop ocaml-lsp-server ocamlformat ocamlformat-rpc && \
    opam user-setup install && \
    eval $(opam env)
