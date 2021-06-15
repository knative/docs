/*
Copyright 2020 The Knative Authors
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
	"context"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"sort"
	"strings"

	"github.com/google/go-github/v32/github"
)

var (
	knativeOrgs   = []string{"knative", "knative-sandbox"}
	allowedRepoRe = regexp.MustCompile("^[a-z][-a-z0-9]+$")
)

// repoInfo provides a simple holder for GitHub repo information needed to
// generate go mod redirects.
type repoInfo struct {
	// Org is the name of the github organization the repo is in.
	Org string
	// Repo is the name of the github repo within the organizatiøon (e.g.
	// "serving", NOT "knative/serving")
	Repo string
	// DefaultBranch is the name of the default branch. This will be changing
	// from "master" to "main" over time.
	DefaultBranch string
}

type riSlice []repoInfo

func main() {
	repos, err := fetchRepos(knativeOrgs)
	if err != nil {
		log.Fatal("Failed to fetch repos: ", err)
	}
	for _, repo := range repos {
		if err := createGoGetFile(repo); err != nil {
			log.Fatalf("Unable to create go mod file for %s: %v", repo, err)
		}
	}
	if err := appendRedirs(repos); err != nil {
		log.Fatal("Failed to write redir file: ", err)
	}
}

func fetchRepos(orgs []string) ([]repoInfo, error) {
	ctx := context.Background()
	allRepos := riSlice{}
	client := github.NewClient(nil)
	for _, org := range orgs {
		opts := &github.RepositoryListByOrgOptions{
			ListOptions: github.ListOptions{PerPage: 50},
		}
		for {
			repos, resp, err := client.Repositories.ListByOrg(ctx, org, opts)
			if err != nil {
				return nil, err
			}
			for _, r := range repos {
				if !allowedRepoRe.MatchString(*r.Name) {
					log.Printf("Ignoring repo %s, matched by ignore %q", *r.Name, allowedRepoRe)
					continue
				}
				if *r.Archived {
					log.Print("Ignoring archived repo: ", *r.Name)
					continue
				}
				allRepos = append(allRepos, repoInfo{org, *r.Name, *r.DefaultBranch})
			}
			if resp.NextPage == 0 {
				break
			}
		}
	}
	sort.Sort(allRepos)
	return allRepos, nil
}

const (
	goHTML = `<html><head>
    <meta name="go-import" content="knative.dev/{{.Repo}} git https://github.com/{{.Org}}/{{.Repo}}">
    <meta name="go-source" content="knative.dev/{{.Repo}}     https://github.com/{{.Org}}/{{.Repo}} https://github.com/{{.Org}}/{{.Repo}}/tree/{{.DefaultBranch}}{/dir} https://github.com/{{.Org}}/{{.Repo}}/blob/{{.DefaultBranch}}{/dir}/{file}#L{line}">
</head></html>
`
	redirText = `/{{.Repo}}/* go-get=1 /golang/{{.Repo}}.html 200
`

	autogenPrefix = `
# This file is AUTO-GENERATED
#
# DO NOT EDIT!
#
# To regenerate, run:
`
)

func appendRedirs(ris []repoInfo) error {
	redirFilename := "golang/_redirects"
	redirFile, err := os.OpenFile(redirFilename, os.O_RDWR|os.O_CREATE, 0755)
	if err != nil {
		return fmt.Errorf("unable to open %q: %w", redirFilename, err)
	}
	defer redirFile.Close()

	redirs, err := ioutil.ReadAll(redirFile)
	if err != nil {
		return fmt.Errorf("unable to read %q: %w", redirFilename, err)
	}

	seekTo := int64(strings.Index(string(redirs), autogenPrefix))
	if seekTo == -1 {
		seekTo = int64(len(redirs))
	}
	if _, err := redirFile.Seek(seekTo, 0); err != nil {
		return fmt.Errorf("unable to seek in %q: %w", redirFilename, err)
	}
	if redirFile.Truncate(seekTo) != nil {
		return fmt.Errorf("unable to truncate %q: %w", redirFilename, err)
	}

	if _, err := redirFile.WriteString(autogenPrefix); err != nil {
		return fmt.Errorf("unable to write to %q: %w", redirFilename, err)
	}
	if _, err := redirFile.WriteString(fmt.Sprintf("#   %s\n", strings.Join(os.Args, " "))); err != nil {
		return fmt.Errorf("unable to write to %q: %w", redirFilename, err)
	}
	for _, ri := range ris {
		if redirTemplate.Execute(redirFile, ri) != nil {
			return fmt.Errorf("unable to write %s to %q: %w", ri.Repo, redirFilename, err)
		}
	}
	return nil
}

var fileTemplate = template.Must(template.New("gohtml").Parse(goHTML))
var redirTemplate = template.Must(template.New("redir").Parse(redirText))

// createGoGetFile creates a static HTML file providing a knative.dev mapping
// for the specified org and repo.
func createGoGetFile(ri repoInfo) error {
	filename := fmt.Sprintf("golang/%s.html", ri.Repo)
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	return fileTemplate.Execute(file, ri)
}

func (ri repoInfo) String() string {
	return ri.Org + "/" + ri.Repo
}

func (ris riSlice) Len() int {
	return len(ris)
}

func (ris riSlice) Less(i, j int) bool {
	return ris[i].Repo < ris[j].Repo
}

func (ris riSlice) Swap(i, j int) {
	ris[i], ris[j] = ris[j], ris[i]

}
