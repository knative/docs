package main

import (
	"flag"
	"fmt"
	"log"
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
	qps         = flag.Int64("qps", 10, "max requests per second")
	concurrency = flag.Int64("concurrency", 10, "max in-flight requests")
	duration    = flag.Duration("duration", time.Minute, "duration of the test")
	verbose     = flag.Bool("verbose", false, "verbose output for debugging")
)

type result struct {
	success    bool
	statusCode int
	latency    time.Duration
}

func get(url string, client *http.Client, report chan *result) {
	start := time.Now()
	result := &result{}
	defer func() {
		result.latency = time.Since(start)
		report <- result
	}()

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		if *verbose {
			fmt.Println("NewRequest:", err)
		}
		return
	}
	req.Host = *host
	res, err := client.Do(req)
	if err != nil {
		if *verbose {
			fmt.Println("Do:", err)
		}
		return
	}
	defer res.Body.Close()
	result.statusCode = res.StatusCode
	if result.statusCode != http.StatusOK {
		if *verbose {
			fmt.Printf("Response: %+v\n", res)
		}
		return
	}
	result.success = true
}

func reporter(stopCh <-chan time.Time, report chan *result, inflight *int64) {
	tickerCh := time.NewTicker(time.Second).C
	var (
		total         int
		count         float64
		successful    float64
		totalDuration time.Duration
	)
	fmt.Println("REQUEST STATS:")
	for {
		select {
		case <-stopCh:
			return
		case <-tickerCh:
			fmt.Printf("Total: %v\tInflight: %v\tDone: %v ", total, atomic.LoadInt64(inflight), count)
			if count > 0 {
				fmt.Printf("\tSuccess Rate: %.2f%%\tAvg Latency: %.4f sec\n",
					successful/count*100, totalDuration.Seconds()/count)
			} else {
				fmt.Printf("\n")
			}
			count = 0
			totalDuration = 0
			successful = 0
		case r := <-report:
			total++
			count++
			totalDuration += r.latency
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
		log.Fatal("Need either $IP_ADDRESS env var or --ip flag")
	}
	url := fmt.Sprintf(
		"http://%v:%v?sleep=%v&prime=%v&bloat=%v",
		*ip, *port, *sleep, *prime, *bloat)
	client := &http.Client{}

	stopCh := time.After(*duration)
	report := make(chan *result, 10000)
	var inflight int64

	go reporter(stopCh, report, &inflight)

	qpsCh := time.NewTicker(time.Duration(time.Second.Nanoseconds() / *qps)).C
	for {
		select {
		case <-stopCh:
			return
		case <-qpsCh:
			if atomic.LoadInt64(&inflight) < *concurrency {
				atomic.AddInt64(&inflight, 1)
				go func() {
					get(url, client, report)
					atomic.AddInt64(&inflight, -1)
				}()
			}
		}
	}
}
