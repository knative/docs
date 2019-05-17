/*
Copyright 2017 The Knative Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"fmt"
	"math"
	"net/http"
	"os"
	"strconv"
	"sync"
	"time"
)

// Algorithm from https://stackoverflow.com/a/21854246

// Only primes less than or equal to N will be generated
func allPrimes(N int) []int {

	var x, y, n int
	nsqrt := math.Sqrt(float64(N))

	is_prime := make([]bool, N)

	for x = 1; float64(x) <= nsqrt; x++ {
		for y = 1; float64(y) <= nsqrt; y++ {
			n = 4*(x*x) + y*y
			if n <= N && (n%12 == 1 || n%12 == 5) {
				is_prime[n] = !is_prime[n]
			}
			n = 3*(x*x) + y*y
			if n <= N && n%12 == 7 {
				is_prime[n] = !is_prime[n]
			}
			n = 3*(x*x) - y*y
			if x > y && n <= N && n%12 == 11 {
				is_prime[n] = !is_prime[n]
			}
		}
	}

	for n = 5; float64(n) <= nsqrt; n++ {
		if is_prime[n] {
			for y = n * n; y < N; y += n * n {
				is_prime[y] = false
			}
		}
	}

	is_prime[2] = true
	is_prime[3] = true

	primes := make([]int, 0, 1270606)
	for x = 0; x < len(is_prime)-1; x++ {
		if is_prime[x] {
			primes = append(primes, x)
		}
	}

	// primes is now a slice that contains all primes numbers up to N
	return primes
}

func bloat(mb int) string {
	b := make([]byte, mb*1024*1024)
	b[0] = 1
	b[len(b)-1] = 1
	return fmt.Sprintf("Allocated %v Mb of memory.\n", mb)
}

func prime(max int) string {
	p := allPrimes(max)
	if len(p) > 0 {
		return fmt.Sprintf("The largest prime less than %v is %v.\n", max, p[len(p)-1])
	} else {
		return fmt.Sprintf("There are no primes smaller than %v.\n", max)
	}
}

func sleep(ms int) string {
	start := time.Now().UnixNano()
	time.Sleep(time.Duration(ms) * time.Millisecond)
	end := time.Now().UnixNano()
	return fmt.Sprintf("Slept for %.2f milliseconds.\n", float64(end-start)/1000000)
}

func parseIntParam(r *http.Request, param string) (int, bool, error) {
	if value := r.URL.Query().Get(param); value != "" {
		i, err := strconv.Atoi(value)
		if err != nil {
			return 0, false, err
		}
		if i == 0 {
			return i, false, nil
		}
		return i, true, nil
	}
	return 0, false, nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	// Validate inputs.
	ms, hasMs, err := parseIntParam(r, "sleep")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	max, hasMax, err := parseIntParam(r, "prime")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	mb, hasMb, err := parseIntParam(r, "bloat")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	// Consume time, cpu and memory in parallel.
	var wg sync.WaitGroup
	defer wg.Wait()
	if hasMs {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Fprint(w, sleep(ms))
		}()
	}
	if hasMax {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Fprint(w, prime(max))
		}()
	}
	if hasMb {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Fprint(w, bloat(mb))
		}()
	}
}

func replyWithToken(token string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, token)
	}
}

func main() {
	validateToken := os.Getenv("VALIDATION")
	if validateToken != "" {
		http.HandleFunc("/"+validateToken+"/", replyWithToken(validateToken))
	}

	listenPort := os.Getenv("PORT")
	if listenPort == "" {
		listenPort = "8080"
	}
	http.HandleFunc("/", handler)
	http.ListenAndServe(":"+listenPort, nil)
}
