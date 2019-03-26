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
)

type allConfigs struct {
	Languages []languageConfig `yaml:"languages`
}

type languageConfig struct {
	Language             string    `yaml:"language"`
	ExpectedOutput       string    `yaml:"expectedOutput"`
	SrcDir               string    `yaml:"srcDir"`  // Directory contains sample code
	WorkDir              string    `yaml:"workDir"` // Temp work directory
	AppName              string    `yaml:"appName"`
	YamlImagePlaceholder string    `yaml:"yamlImagePlaceholder"` // Token to be replaced by real docker image URI
	PreCommands          []command `yaml:"preCommands"`          // Commands to be ran before copying
	Copies               []string  `yaml:"copies"`               // Files to be copied from SrcDir to WorkDir
	PostCommands         []command `yaml:"postCommands"`         // Commands to be ran after copying
}

type command struct {
	Exec string `yaml:"exec"`
	Args string `yaml:"args"`
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

func getConfigs(configPath string) (allConfigs, error) {
	var lcs allConfigs
	content, err := ioutil.ReadFile(configPath)
	if nil == err {
		err = yaml.Unmarshal(content, &lcs)
	}
	return lcs, err
}
