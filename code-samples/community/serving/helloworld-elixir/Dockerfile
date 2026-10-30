FROM hexpm/elixir:1.20.4-erlang-29.1.2-alpine-3.24.3 AS build

ENV MIX_ENV=prod
WORKDIR /app
RUN apk add --no-cache build-base git \
    && mix local.hex --force \
    && mix local.rebar --force
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod && mix deps.compile
COPY lib lib
COPY priv priv
RUN mix compile --warnings-as-errors \
    && mix phx.digest \
    && mix release

# Same Alpine/OpenSSL ABI as the builder; no compiler, Node or Mix in the runtime.
FROM alpine:3.24.3 AS runtime
RUN apk add --no-cache libstdc++ ncurses-libs openssl ca-certificates \
    && addgroup -S appuser && adduser -S -G appuser appuser
WORKDIR /app
COPY --from=build --chown=appuser:appuser /app/_build/prod/rel/hello ./
USER appuser
ENV HOME=/app LANG=C.UTF-8
EXPOSE 8080
CMD ["/app/bin/hello", "start"]
