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
	"strings"
)

// Flags holds the command line flags or defaults for settings in the user's environment.
// See EnvironmentFlags for a list of supported fields.
var Flags = initializeFlags()

// EnvironmentFlags define the flags that are needed to run the e2e tests.
type EnvironmentFlags struct {
	Languages string // Allowed languages to run
}

func initializeFlags() *EnvironmentFlags {
	var f EnvironmentFlags
	flag.StringVar(&f.Languages, "languages", "", "Comma separated languages to run e2e test on.")

	return &f
}

// GetAllowedLanguages is a helper function to return a map of allowed languages based on Languages filter
func GetAllowedLanguages() map[string]bool {
	allowed := make(map[string]bool)
	if "" != Flags.Languages {
		for _, l := range strings.Split(Flags.Languages, ",") {
			allowed[l] = true
		}
	}
	return allowed
}
