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
	"os/exec"
	"strings"
	"testing"
)

const (
	// using these defaults if not provided, see useDefaultIfNotProvided function below
	defaultSrcDir               = "../../docs/serving/samples/hello-world/helloworld-%s"
	defaultWorkDir              = "helloworld-%s_tmp"
	defaultAppName              = "helloworld-%s"
	defaultYamlImagePlaceHolder = "docker.io/{username}/helloworld-%s"
)

type languageConfig struct {
	Language             string
	SrcDir               string // Directory contains sample code
	WorkDir              string // Temp work directory
	AppName              string
	YamlImagePlaceholder string    // Token to be replaced by real docker image URI
	PreCommands          []command // Commands to be ran before copying
	Copies               []string  // Files to be copied from SrcDir to WorkDir
	PostCommands         []command // Commands to be ran after copying
}

type command struct {
	Exec string
	Args string
}

func (lc *languageConfig) useDefaultIfNotProvided() {
	if "" == lc.SrcDir {
		lc.SrcDir = fmt.Sprintf(defaultSrcDir, lc.Language)
	}
	if "" == lc.WorkDir {
		lc.WorkDir = fmt.Sprintf(defaultWorkDir, lc.Language)
	}
	if "" == lc.AppName {
		lc.AppName = fmt.Sprintf(defaultAppName, lc.Language)
	}
	if "" == lc.YamlImagePlaceholder {
		lc.YamlImagePlaceholder = fmt.Sprintf(defaultYamlImagePlaceHolder, lc.Language)
	}
}

func (c *command) run(t *testing.T) {
	args := strings.Split(c.Args, " ")
	if output, err := exec.Command(c.Exec, args...).CombinedOutput(); err != nil {
		t.Fatalf("Error executing: '%s' '%s' -err: '%v'", c.Exec, c.Args, strings.TrimSpace(string(output)))
	}
}

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
