FROM golang:1.11

WORKDIR /go/src/invoke
COPY . .

RUN go install -v

CMD ["invoke"]
