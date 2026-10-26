FROM golang:1.27 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY main.go ./
RUN go vet ./... && CGO_ENABLED=0 go build -mod=readonly -trimpath -ldflags="-s -w" -o /parallel .

FROM scratch
COPY --from=build /parallel /parallel
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/parallel"]
