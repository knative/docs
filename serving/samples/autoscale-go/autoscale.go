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
	"math"
	"net/http"
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

func bloat(mb int) {
	b := make([]byte, mb*1024*1024)
	b[0] = 1
	b[len(b)-1] = 1
}

func prime(max int) {
	p := allPrimes(max)
}

func sleep(ms int) {
	time.Sleep(time.Duration(ms) * time.Millisecond)
}

func run(wg sync.WaitGroup, value string, fn func(int)) error {
	i, err := strconv.Atoi(value)
	if err != nil {
		return err
	}
	go func() {
		wg.Add(1)
		defer wg.Done()
		fn(i)
	}()
	return nil
}

func parseInt(r *http.Request, param string) (int, ok, error) {
	if value, ok := r.URL.Query()[param]; ok {

	}
	return 0, false, nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	values := r.URL.Query()
	var wg sync.WaitGroup
	defer wg.Wait()
	ms,



	if ms, ok := values["sleep"]; ok {
		if err := run(wg, ms, sleep); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
	}
	if max, ok := values["prime"]; ok {
		if err := run(wg, max, prime); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
	}
	if mb, ok := values["bloat"]; ok {
		if err := run(wg, mb, bloat); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
	}
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
