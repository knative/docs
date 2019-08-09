# Build executable binary
FROM golang:1.11 AS builder

WORKDIR $GOPATH

COPY invoke.go .
RUN go build -o /go/bin/invoke

# Build r-base image
FROM r-base:3.6.0

# Copy Go binary
COPY --from=builder /go/bin/invoke /go/bin/invoke
COPY HelloWorld.R .

ENTRYPOINT ["/go/bin/invoke"]
