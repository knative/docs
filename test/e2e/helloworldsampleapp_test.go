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
	"fmt"
	"testing"
)

// TestSampleApp runs all sample apps from different languages
func TestSampleApp(t *testing.T) {
	tests := []struct {
		lc          languageConfig
		expectedOut string
	}{
		{
			languageConfig{
				Language: "java",
				PreCommands: []command{
					{
						"curl",
						"https://start.spring.io/starter.zip -d dependencies=web -d name=helloworld -d artifactId=helloworld -o helloworld.zip",
					},
					{
						"unzip",
						"helloworld.zip -d helloworld-java_tmp",
					},
					{
						"rm",
						"helloworld.zip",
					},
				},
				Copies: []string{
					"/src/main/java/com/example/helloworld/HelloworldApplication.java",
					"service.yaml",
					"Dockerfile",
				},
			},
			"Hello Spring Boot Sample v1!",
		},
		{
			languageConfig{
				Language: "go",
				Copies: []string{
					"helloworld.go",
					"service.yaml",
					"Dockerfile",
				},
			},
			"Hello Go Sample v1!",
		},
	}

	for _, test := range tests {
		test.lc.useDefaultIfNotProvided()
		t.Run(fmt.Sprintf("language-%s", test.lc.Language), func(t *testing.T) {
			SampleAppTestBase(t, test.lc, test.expectedOut)
		})
	}
}
