# Build with the current stable Swift toolchain on Ubuntu 24.04 LTS.
FROM swift:6.4.1-noble AS build
WORKDIR /app
COPY Package.swift Package.resolved ./
RUN swift package resolve --force-resolved-versions
COPY Sources ./Sources
RUN swift build -c release --jobs 2 --force-resolved-versions

# Ship only the executable and matching Swift runtime, not the compiler.
FROM swift:6.4.1-noble-slim AS runtime
WORKDIR /app
COPY --from=build /app/.build/release/HelloSwift ./HelloSwift
USER 10001:10001
EXPOSE 8080
CMD ["./HelloSwift"]
