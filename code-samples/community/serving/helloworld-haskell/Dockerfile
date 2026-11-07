# syntax=docker/dockerfile:1
# GHCup-recommended / Stackage LTS compiler; pin the multi-architecture image.
FROM haskell:9.12.2-slim-bookworm@sha256:c83dcb092fff03ab85a6febf903f7ac378983ddadda53bb6da31ea74d70546f4 AS builder
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
