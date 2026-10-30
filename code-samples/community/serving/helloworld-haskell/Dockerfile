# syntax=docker/dockerfile:1
# GHCup-recommended / Stackage LTS compiler; pin the multi-architecture image.
FROM haskell:9.10.3-slim-bookworm@sha256:3c9f47467dbd6cb62c6ec6b768270c627bc33565e209bece103b7484075b27e3 AS builder
ENV CABAL_DIR=/root/.cabal
WORKDIR /src
COPY helloworld-haskell.cabal cabal.project cabal.project.freeze LICENSE ./
RUN --mount=type=cache,id=docs-audit-community-helloworld-haskell-cabal,target=/root/.cabal \
    cabal update && cabal build --only-dependencies all
COPY app ./app
RUN --mount=type=cache,id=docs-audit-community-helloworld-haskell-cabal,target=/root/.cabal \
    cabal check \
    && cabal build all --ghc-options=-Werror \
    && mkdir /out \
    && cp "$(cabal list-bin exe:helloworld-haskell-exe)" /out/helloworld-haskell-exe \
    && strip /out/helloworld-haskell-exe \
    && ldd /out/helloworld-haskell-exe

# Same Debian ABI, without GHC/Cabal or build dependencies in the final image.
FROM debian:bookworm-slim@sha256:7ff6ba31527b9e336162fa061746c366c4b2032f4d2cff2078bea43f78efe3f8
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgmp10 zlib1g \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=C.UTF-8
WORKDIR /app
COPY --from=builder /out/helloworld-haskell-exe .
USER 65532:65532
CMD ["./helloworld-haskell-exe"]
