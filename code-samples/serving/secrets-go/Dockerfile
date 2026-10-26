# Standard-library-only build using the supported Go 1.27 release track.
FROM golang:1.27 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -o /hellosecrets .

# No shell, SDK, package manager, CA store or outbound service is required.
FROM scratch
COPY --from=builder /hellosecrets /hellosecrets
USER 65532:65532
ENTRYPOINT ["/hellosecrets"]
