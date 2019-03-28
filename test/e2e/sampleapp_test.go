// +build e2e

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

package e2etest

import (
	"testing"

	"github.com/knative/docs/test/sampleapp"

	"github.com/knative/docs/test"
)

const (
	configFile = "../sampleapp/config.yaml"
)

// TestSampleApp runs all sample apps from different languages
func TestSampleApp(t *testing.T) {
	lcs, err := sampleapp.GetConfigs(configFile)
	if nil != err {
		t.Fatalf("Failed reading config file %s: '%v'", configFile, err)
	}

	whitelist := test.GetWhitelistedLanguages()
	for _, lc := range lcs.Languages {
		if _, ok := whitelist[lc.Language]; len(whitelist) > 0 && !ok {
			continue
		}
		lc.UseDefaultIfNotProvided()
		t.Run(lc.Language, func(t *testing.T) {
			SampleAppTestBase(t, lc, lc.ExpectedOutput)
		})
	}
}
