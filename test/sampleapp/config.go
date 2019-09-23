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

package sampleapp

import (
	"fmt"
	"io/ioutil"
	"os/exec"
	"strings"
	"testing"

	yaml "gopkg.in/yaml.v2"
)

const (
	// using these defaults if not provided, see useDefaultIfNotProvided function below
	defaultSrcDir               = "../../docs/serving/samples/hello-world/helloworld-%s"
	defaultWorkDir              = "helloworld-%s_tmp"
	defaultAppName              = "helloworld-%s"
	defaultYamlImagePlaceHolder = "docker.io/{username}/helloworld-%s"

	// ActionMsg serves as documentation purpose, which will be referenced for
	// clearly displaying error messages.
	ActionMsg = "All files required for running sample apps are checked " +
		"against README.md, the content of source files should be identical with what's " +
		"in README.md file, the list of the files to be verified is the same set of files " +
		"used for running sample apps, they are configured in `/test/sampleapp/config.yaml`. " +
		"If an exception is needed the file can be configured to be copied as a separate step " +
		"in `PreCommand` such as: " +
		"https://github.com/knative/docs/blob/65f7b402fee7f94dfbd9e4512ef3beed7b85de66/test/sampleapp/config.yaml#L4"
)

// AllConfigs contains all LanguageConfig
type AllConfigs struct {
	Languages []LanguageConfig `yaml:"languages`
}

// LanguageConfig contains all information for building/deploying an app
type LanguageConfig struct {
	Language             string    `yaml:"language"`
	ExpectedOutput       string    `yaml:"expectedOutput"`
	SrcDir               string    `yaml:"srcDir"`  // Directory contains sample code
	WorkDir              string    `yaml:"workDir"` // Temp work directory
	AppName              string    `yaml:"appName"`
	YamlImagePlaceholder string    `yaml:"yamlImagePlaceholder"` // Token to be replaced by real docker image URI
	PreCommands          []Command `yaml:"preCommands"`          // Commands to be ran before copying
	Copies               []string  `yaml:"copies"`               // Files to be copied from SrcDir to WorkDir
	PostCommands         []Command `yaml:"postCommands"`         // Commands to be ran after copying
}

// Command contains shell commands
type Command struct {
	Exec string `yaml:"exec"`
	Args string `yaml:"args"`
}

// UseDefaultIfNotProvided sets default value to SrcDir, WorkDir, AppName, and YamlImagePlaceholder if not provided
func (lc *LanguageConfig) UseDefaultIfNotProvided() {
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

// Run runs command and fail if it failed
func (c *Command) Run(t *testing.T) {
	args := strings.Split(c.Args, " ")
	if output, err := exec.Command(c.Exec, args...).CombinedOutput(); err != nil {
		t.Fatalf("Error executing: '%s' '%s' -err: '%v'", c.Exec, c.Args, strings.TrimSpace(string(output)))
	}
}

// GetConfigs parses a config yaml file and return AllConfigs struct
func GetConfigs(configPath string) (AllConfigs, error) {
	var lcs AllConfigs
	content, err := ioutil.ReadFile(configPath)
	if nil == err {
		err = yaml.Unmarshal(content, &lcs)
	}
	return lcs, err
}
