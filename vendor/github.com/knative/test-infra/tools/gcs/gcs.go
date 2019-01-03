/*
Copyright 2018 The Knative Authors

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

// gcs.go defines functions to use GCS

package gcs

import (
	"bufio"
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"

	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

const (
	bucketName = "knative-prow"
	latest     = "/latest-build.txt"
)

var client *storage.Client

func createStorageClient(ctx context.Context, sa string) error {
	var err error
	client, err = storage.NewClient(ctx, option.WithCredentialsFile(sa))
	return err
}

func createStorageObject(filename string) *storage.ObjectHandle {
	return client.Bucket(bucketName).Object(filename)
}

// GetLatestBuildNumber gets the latest build number for the specified log directory
func GetLatestBuildNumber(ctx context.Context, logDir string, sa string) (int, error) {
	logFilePath := logDir + latest
	log.Printf("Using %s to get latest build number", logFilePath)
	contents, err := ReadGcsFile(ctx, logFilePath, sa)
	if err != nil {
		return 0, err
	}
	latestBuild, err := strconv.Atoi(string(contents))
	if err != nil {
		return 0, err
	}

	return latestBuild, nil
}

//ReadGcsFile reads the specified file using the provided service account
func ReadGcsFile(ctx context.Context, filename string, sa string) ([]byte, error) {
	// Create a new GCS client
	if err := createStorageClient(ctx, sa); err != nil {
		log.Fatalf("Failed to create GCS client: %v", err)
	}
	o := createStorageObject(filename)
	if _, err := o.Attrs(ctx); err != nil {
		return []byte(fmt.Sprintf("Cannot get attributes of '%s'", filename)), err
	}
	f, err := o.NewReader(ctx)
	if err != nil {
		return []byte(fmt.Sprintf("Cannot open '%s'", filename)), err
	}
	defer f.Close()
	contents, err := ioutil.ReadAll(f)
	if err != nil {
		return []byte(fmt.Sprintf("Cannot read '%s'", filename)), err
	}
	return contents, nil
}

// ParseLog parses the log and returns the lines where the checkLog func does not return an empty slice.
// checkLog function should take in the log statement and return a part from that statement that should be in the log output.
func ParseLog(ctx context.Context, filename string, checkLog func(s []string) *string) []string {
	var logs []string

	log.Printf("Parsing '%s'", filename)
	o := createStorageObject(filename)
	if _, err := o.Attrs(ctx); err != nil {
		log.Printf("Cannot get attributes of '%s', assuming not ready yet: %v", filename, err)
		return nil
	}
	f, err := o.NewReader(ctx)
	if err != nil {
		log.Fatalf("Error opening '%s': %v", filename, err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		if s := checkLog(strings.Fields(scanner.Text())); s != nil {
			logs = append(logs, *s)
		}
	}
	return logs
}
