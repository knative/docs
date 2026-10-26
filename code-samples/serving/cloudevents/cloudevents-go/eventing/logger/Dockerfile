FROM golang:1.27 AS builder
WORKDIR /src
COPY capture.go ./
RUN CGO_ENABLED=0 go build -o /capture capture.go
FROM alpine:3.24
COPY --from=builder /capture /capture
ENTRYPOINT ["/capture"]
