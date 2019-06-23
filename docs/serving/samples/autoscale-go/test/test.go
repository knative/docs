package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"sync/atomic"
	"time"
)

var (
	sleep       = flag.Int("sleep", 0, "milliseconds to sleep")
	prime       = flag.Int("prime", 0, "calculate largest prime less than")
	bloat       = flag.Int("bloat", 0, "mb of memory to consume")
	ip          = flag.String("ip", "", "ip address of knative ingress")
	port        = flag.String("port", "80", "port of call")
	host        = flag.String("host", "autoscale-go.default.example.com", "host name of revision under test")
	qps         = flag.Int("qps", 10, "max requests per second")
	concurrency = flag.Int("concurrency", 10, "max in-flight requests")
	duration    = flag.Duration("duration", time.Minute, "duration of the test")
	verbose     = flag.Bool("verbose", false, "verbose output for debugging")
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
		if *verbose {
			fmt.Printf("%v\n", err)
		}
		return
	}
	req.Host = *host
	res, err := client.Do(req)
	if err != nil {
		if *verbose {
			fmt.Printf("%v\n", err)
		}
		return
	}
	defer res.Body.Close()
	result.statusCode = res.StatusCode
	if result.statusCode != http.StatusOK {
		if *verbose {
			fmt.Printf("%+v\n", res)
		}
		return
	}
	result.success = true
}

func reporter(stopCh <-chan time.Time, report chan *result, inflight *int64) {
	tickerCh := time.NewTicker(time.Second).C
	var (
		total       int64
		count       int64
		nanoseconds int64
		successful  int64
	)
	fmt.Println("REQUEST STATS:")
	for {
		select {
		case <-stopCh:
			return
		case <-tickerCh:
			fmt.Printf("Total: %v\tInflight: %v\tDone: %v ", total, atomic.LoadInt64(inflight), count)
			if count > 0 {
				fmt.Printf("\tSuccess Rate: %.2f%%\tAvg Latency: %.4f sec\n", float64(successful)/float64(count)*100, float64(nanoseconds)/float64(count)/(1000000000))
			} else {
				fmt.Printf("\n")
			}
			count = 0
			nanoseconds = 0
			successful = 0
		case r := <-report:
			total++
			count++
			nanoseconds += r.latency
			if r.success {
				successful++
			}
		}
	}
}

func main() {
	flag.Parse()
	if *ip == "" {
		ipAddress := os.Getenv("IP_ADDRESS")
		ip = &ipAddress
	}
	if *ip == "" {
		panic("need either $IP_ADDRESS env var or --ip flag")
	}
	url := fmt.Sprintf(
		"http://%v:%v?sleep=%v&prime=%v&bloat=%v",
		*ip, *port, *sleep, *prime, *bloat)
	client := &http.Client{}

	stopCh := time.After(*duration)
	report := make(chan *result, 10000)
	var inflight int64

	go reporter(stopCh, report, &inflight)

	qpsCh := time.NewTicker(time.Duration(time.Second.Nanoseconds() / int64(*qps))).C
	for {
		select {
		case <-stopCh:
			return
		case <-qpsCh:
			if atomic.LoadInt64(&inflight) < int64(*concurrency) {
				atomic.AddInt64(&inflight, 1)
				go func() {
					get(url, client, report)
					atomic.AddInt64(&inflight, -1)
				}()
			}
		}
	}
}
