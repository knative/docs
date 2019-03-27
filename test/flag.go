/*
Copyright 2019 The Knative Authors

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

package test

import (
	"flag"
	"fmt"
	"os"
	"strings"
)

// Flags holds the command line flags or defaults for settings in the user's environment.
// See EnvironmentFlags for a list of supported fields.
var Flags = initializeFlags()

// EnvironmentFlags define the flags that are needed to run the e2e tests.
type EnvironmentFlags struct {
	Cluster     string // K8s cluster (defaults to cluster in kubeconfig)
	LogVerbose  bool   // Enable verbose logging
	DockerRepo  string // Docker repo (defaults to $KO_DOCKER_REPO)
	EmitMetrics bool   // Emit metrics
	Tag         string // Docker image tag
	Languages   string // Whitelisted languages to run
}

func initializeFlags() *EnvironmentFlags {
	var f EnvironmentFlags
	flag.StringVar(&f.Cluster, "cluster", "",
		"Provide the cluster to test against. Defaults to the current cluster in kubeconfig.")

	flag.BoolVar(&f.LogVerbose, "logverbose", false,
		"Set this flag to true if you would like to see verbose logging.")

	flag.BoolVar(&f.EmitMetrics, "emitmetrics", false,
		"Set this flag to true if you would like tests to emit metrics, e.g. latency of resources being realized in the system.")

	flag.StringVar(&f.DockerRepo, "dockerrepo", os.Getenv("KO_DOCKER_REPO"),
		"Provide the uri of the docker repo you have uploaded the test image to using `uploadtestimage.sh`. Defaults to $KO_DOCKER_REPO")

	flag.StringVar(&f.Tag, "tag", "latest", "Provide the version tag for the test images.")

	flag.StringVar(&f.Languages, "languages", "", "Comma separated languages to run e2e test on.")

	return &f
}

// ImagePath is a helper function to prefix image name with repo and suffix with tag
func ImagePath(name string) string {
	return fmt.Sprintf("%s/%s:%s", Flags.DockerRepo, name, Flags.Tag)
}

// GetWhitelistedLanguages is a helper function to return a map of whitelisted languages based on Languages filter
func GetWhitelistedLanguages() map[string]bool {
	whitelist := make(map[string]bool)
	if "" != Flags.Languages {
		for _, l := range strings.Split(Flags.Languages, ",") {
			whitelist[l] = true
		}
	}
	return whitelist
}
