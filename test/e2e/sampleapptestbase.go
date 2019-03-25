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
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"os/signal"
	"path"
	"strings"
	"testing"
	"time"
)

const (
	servingNamespace = "default"
	ingressTimeout   = 5 * time.Minute
	servingTimeout   = 2 * time.Minute
	checkInterval    = 2 * time.Second
)

// CleanupOnInterrupt will execute the function cleanup if an interrupt signal is caught
func CleanupOnInterrupt(cleanup func()) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for range c {
			cleanup()
			os.Exit(1)
		}
	}()
}

func noStderrShell(name string, arg ...string) string {
	var void bytes.Buffer
	cmd := exec.Command(name, arg...)
	cmd.Stderr = &void
	out, _ := cmd.Output()
	return string(out)
}

func cleanup(yamlFilePath, workDir string) {
	exec.Command("kubectl", "delete", "-f", yamlFilePath).Run()
	os.Remove(yamlFilePath)
	os.RemoveAll(workDir)
}

func serviceHostname(appName string) string {
	return noStderrShell("kubectl", "get", "rt", appName, "-o", "jsonpath={.status.domain}", "-n", servingNamespace)
}

func ingressAddress(gateway string, addressType string) string {
	return noStderrShell("kubectl", "get", "svc", gateway, "-n", "istio-system",
		"-o", fmt.Sprintf("jsonpath={.status.loadBalancer.ingress[*]['%s']}", addressType))
}

func prepareWorkDir(t *testing.T, srcDir, workDir string, preCommands []command, copies []string, postCommands []command) {
	t.Log("Prepare source project")
	err := os.RemoveAll(workDir) // this function returns nil if path not found
	if nil == err {
		if _, err = os.Stat(workDir); os.IsNotExist(err) {
			err = os.MkdirAll(workDir, 0755)
		}
	}
	if nil != err {
		t.Fatalf("Failed preparing local artifacts directory: %v", err)
	}

	for _, c := range preCommands {
		c.run(t)
	}
	for _, f := range copies {
		src := path.Join(srcDir, f)
		dst := path.Join(workDir, f)
		if output, err := exec.Command("cp", src, dst).CombinedOutput(); err != nil {
			t.Fatalf("Error copying: '%s' to '%s' -err: '%v'", src, dst, strings.TrimSpace(string(output)))
		}
	}
	for _, c := range postCommands {
		c.run(t)
	}
}

func pushDockerImage(t *testing.T, imagePath, workDir string) {
	t.Logf("Pushing docker image to: '%s'", imagePath)
	if output, err := exec.Command("docker", "build", "-t", imagePath, workDir).CombinedOutput(); err != nil {
		t.Fatalf("Error building docker image: %v", strings.TrimSpace(string(output)))
	}
	if output, err := exec.Command("docker", "push", imagePath).CombinedOutput(); err != nil {
		t.Fatalf("Error pushing docker image: %v", strings.TrimSpace(string(output)))
	}
}

func deploy(t *testing.T, yamlFilePath, yamlImagePlaceholder, imagePath string) {
	t.Log("Creating manifest")
	// Populate manifets file with the real path to the container
	yamlBytes, err := ioutil.ReadFile(yamlFilePath)
	if err != nil {
		t.Fatalf("Failed to read file %s: %v", yamlFilePath, err)
	}
	content := strings.Replace(string(yamlBytes), yamlImagePlaceholder, imagePath, -1)
	if err = ioutil.WriteFile(yamlFilePath, []byte(content), 0644); err != nil {
		t.Fatalf("Failed to write new manifest: %v", err)
	}

	t.Logf("Deploying using kubectl and using manifest file %q", yamlFilePath)
	// Deploy using kubectl
	if output, err := exec.Command("kubectl", "apply", "-f", yamlFilePath).CombinedOutput(); err != nil {
		t.Fatalf("Error running kubectl: %v", strings.TrimSpace(string(output)))
	}
}

func checkDeployment(t *testing.T, appName, expectedOutput string) {
	t.Log("Waiting for ingress to come up")
	gateway := "istio-ingressgateway"
	// Wait for ingress to come up
	ingressAddr := ""
	serviceHost := ""
	timeout := ingressTimeout
	for (ingressAddr == "" || serviceHost == "") && timeout >= 0 {
		if serviceHost == "" {
			serviceHost = serviceHostname(appName)
		}
		if ingressAddr = ingressAddress(gateway, "ip"); ingressAddr == "" {
			ingressAddr = ingressAddress(gateway, "hostname")
		}
		timeout -= checkInterval
		time.Sleep(checkInterval)
	}
	if ingressAddr == "" || serviceHost == "" {
		// serviceHost or ingressAddr might contain a useful error, dump them.
		t.Fatalf("Ingress not found (ingress='%s', host='%s')", ingressAddr, serviceHost)
	}
	t.Logf("Curling %s/%s", ingressAddr, serviceHost)

	outputString := ""
	timeout = servingTimeout
	for outputString != expectedOutput && timeout >= 0 {
		output, err := exec.Command("curl", "--header", "Host:"+serviceHost, "http://"+ingressAddr).Output()
		errorString := "none"
		if err != nil {
			errorString = err.Error()
		}
		outputString = strings.TrimSpace(string(output))
		t.Logf("App replied with '%s' (error: %s)", outputString, errorString)
		timeout -= checkInterval
		time.Sleep(checkInterval)
	}

	if outputString != expectedOutput {
		t.Fatal("Timeout waiting for app to start serving")
	}
	t.Log("App is serving")
}

// SampleAppTestBase tests individual sample app
func SampleAppTestBase(t *testing.T, lc languageConfig, expectedOutput string) {
	imagePath := ImagePath(lc.AppName)
	yamlFilePath := path.Join(lc.WorkDir, "service.yaml")

	CleanupOnInterrupt(func() { cleanup(yamlFilePath, lc.WorkDir) })
	defer cleanup(yamlFilePath, lc.WorkDir)

	prepareWorkDir(t, lc.SrcDir, lc.WorkDir, lc.PreCommands, lc.Copies, lc.PostCommands)
	pushDockerImage(t, imagePath, lc.WorkDir)

	// Deploy and test
	deploy(t, yamlFilePath, lc.YamlImagePlaceholder, imagePath)
	checkDeployment(t, lc.AppName, expectedOutput)
}
