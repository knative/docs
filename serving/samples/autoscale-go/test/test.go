package main

import (
	"flag"
	"fmt"
	"net/http"
	"sync/atomic"
	"time"
)

var (
	sleep       = flag.Int("sleep", 0, "milliseconds to sleep")
	prime       = flag.Int("prime", 0, "calculate largest prime less than")
	bloat       = flag.Int("bloat", 0, "mb of memory to consume")
	ip          = flag.String("ip", "127.0.0.1", "ip address of knative ingress")
	port        = flag.String("port", "8080", "port of call")
	host        = flag.String("host", "localhost", "host name of revision under test")
	qps         = flag.Int("qps", 10, "max requests per second")
	concurrency = flag.Int("concurrency", 10, "max in-flight requests")
	duration    = flag.Duration("duration", time.Minute, "duration of the test")
)

type result struct {
	success    bool
	statusCode int
	latency    int64
}

func get(url string, client *http.Client, report chan *result) {
	start := time.Now()
	result := &result{}
	defer func() {
		end := time.Now()
		result.latency = end.UnixNano() - start.UnixNano()
		report <- result
	}()

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return
	}
	req.Host = *host
	res, err := client.Do(req)
	if err != nil {
		return
	}
	result.statusCode = res.StatusCode
	if result.statusCode != http.StatusOK {
		return
	}
	result.success = true
}

func reporter(report chan *result, inflight *int64) {
	tickerCh := time.NewTicker(time.Second).C
	var (
		count       int64
		nanoseconds int64
		successful  int64
	)
	fmt.Println("REQUEST STATS:")
	for {
		select {
		case <-tickerCh:
			fmt.Printf("Currently inflight: %v\tCompleted: %v", atomic.LoadInt64(inflight), count)
			if count > 0 {
				fmt.Printf("\tSuccess Rate: %.2f%%\tAvg Latency: %.4f sec\n", float64(successful)/float64(count)*100, float64(nanoseconds)/float64(count)/(1000000000))
			} else {
				fmt.Printf("\n")
			}
			count = 0
			nanoseconds = 0
			successful = 0
		case r := <-report:
			count = count + 1
			nanoseconds = nanoseconds + r.latency
			if r.success {
				successful = successful + 1
			}
		}
	}
}

func main() {
	flag.Parse()
	url := fmt.Sprintf(
		"http://%v:%v?sleep=%v&prime=%v&bloat=%v",
		*ip, *port, *sleep, *prime, *bloat)
	client := &http.Client{}
	report := make(chan *result, 10000)
	var inflight int64
	go reporter(report, &inflight)

	qpsCh := time.NewTicker(time.Duration(time.Second.Nanoseconds() / int64(*qps))).C
	for {
		<-qpsCh
		if atomic.LoadInt64(&inflight) < int64(*concurrency) {
			atomic.AddInt64(&inflight, 1)
			go func() {
				get(url, client, report)
				atomic.AddInt64(&inflight, -1)
			}()
		}
	}
}
