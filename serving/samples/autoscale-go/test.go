package main

import (
	"flag"
	"fmt"
	"net/http"
)

var (
	sleep = flag.Int("sleep", 0, "milliseconds to sleep")
	prime = flag.Int("prime", 0, "calculate largest prime less than")
	bloat = flag.Int("bloat", 0, "mb of memory to consume")
	ip    = flag.String("ip", "127.0.0.1", "ip address of knative ingress")
	port  = flag.String("port", "8080", "port of call")
	host  = flag.String("host", "localhost", "host name of revision under test")
)

func main() {
	flag.Parse()
	url := fmt.Sprintf("http://%v:%v?sleep=%v&prime=%v&bloat=%v", *ip, *port, *sleep, *prime, *bloat)
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		panic(err)
	}
	req.Host = *host
	_, err = client.Do(req)
	if err != nil {
		panic(err)
	}
}
