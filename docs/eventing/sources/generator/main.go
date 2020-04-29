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

package main

import (
	"flag"
	"io/ioutil"
	"log"
	"os"
	"sort"
	"text/template"

	yaml "gopkg.in/yaml.v2"
)

var (
	yamlFile     = flag.String("yaml", "docs/eventing/sources/sources.yaml", "The YAML file to parse to generate the mark down.")
	templateFile = flag.String("template", "docs/eventing/sources/generator/ReadmeTemplate.gomd", "The template file to fill in.")
	mdFile       = flag.String("md", "docs/eventing/sources/README.md", "The mark down file to write to. Any existing file will be overwritten.")
)

func main() {
	flag.Parse()

	yamlSources := parseYaml()
	tmpl := createTemplate()
	writeMarkdown(yamlSources, tmpl)
}

func parseYaml() *yamlSources {
	fileBytes, err := ioutil.ReadFile(*yamlFile)
	if err != nil {
		log.Fatalf("Unable to read the YAML file '%s': %v", *yamlFile, err)
	}

	sources := &yamlSources{}
	err = yaml.UnmarshalStrict(fileBytes, sources)
	if err != nil {
		log.Fatalf("Unable to unmarshal the YAML file '%s': %v", *yamlFile, err)
	}

	// Sort the three lists.
	sortAlphabetically(sources.MetaSources)
	sortAlphabetically(sources.Sources)
	sortAlphabetically(sources.Containers)
	sortAlphabetically(sources.SinkBindings)

	return sources
}

func sortAlphabetically(slice []source) {
	sortByName := func(i, j int) bool {
		return slice[i].Name < slice[j].Name
	}
	sort.SliceStable(slice, sortByName)
}

type yamlSources struct {
	MetaSources  []source `yaml:"metaSources"`
	Sources      []source `yaml:"sources"`
	Containers   []source `yaml:"containers"`
	SinkBindings []source `yaml:"sinkBindings"`
}

type source struct {
	Name        string `yaml:"name"`
	Url         string `yaml:"url"`
	Status      string `yaml:"status"` // TODO Make this an enum.
	Support     string `yaml:"support"`
	Description string `yaml:"description"`
}

func createTemplate() *template.Template {
	fileBytes, err := ioutil.ReadFile(*templateFile)
	if err != nil {
		log.Fatalf("Unable to read the template file '%s': %v", *templateFile, err)
	}
	fileString := string(fileBytes)
	tmpl, err := template.New("markdown template").Parse(fileString)
	if err != nil {
		log.Fatalf("Unable to parse the template file '%s': %v", *templateFile, err)
	}
	return tmpl
}

func writeMarkdown(yamlSources *yamlSources, tmpl *template.Template) {
	md, err := os.Create(*mdFile)
	if err != nil {
		log.Fatalf("Unable to create the markdown file '%s': %v", *mdFile, err)
	}
	defer md.Close()

	err = tmpl.Execute(md, yamlSources)
	if err != nil {
		log.Fatalf("Unable to execute the template: %v", err)
	}
}
