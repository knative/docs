/*
Copyright 2018 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	ghclient "github.com/google/go-github/github"
	"github.com/knative/eventing/pkg/event"
	"golang.org/x/oauth2"
	"gopkg.in/go-playground/webhooks.v3/github"
	"log"
	"net/http"
	"os"
	"strings"
)

const (
	// Environment variable containing json credentials
	envSecret = "GITHUB_SECRET"
	// this is what we tack onto each PR title if not there already
	titleSuffix = "looks pretty legit"
)

// GithubHandler holds necessary objects for communicating with the Github.
type GithubHandler struct {
	client *ghclient.Client
	ctx    context.Context
}

type GithubSecrets struct {
	AccessToken string `json:"accessToken"`
	SecretToken string `json:"secretToken"`
}

func (h *GithubHandler) newPullRequestPayload(ctx context.Context, pl *github.PullRequestPayload) {

	title := pl.PullRequest.Title
	log.Printf("GOT PR with Title: %q", title)

	// Check the title and if it contains 'looks pretty legit' leave it alone
	if strings.Contains(title, titleSuffix) {
		// already modified, leave it alone.
		return
	}

	newTitle := fmt.Sprintf("%s (%s)", title, titleSuffix)
	updatedPR := ghclient.PullRequest{
		Title: &newTitle,
	}
	newPR, response, err := h.client.PullRequests.Edit(h.ctx,
		pl.Repository.Owner.Login, pl.Repository.Name, int(pl.Number), &updatedPR)
	if err != nil {
		log.Printf("Failed to update PR: %s\n%s", err, response)
		return
	}
	if newPR.Title != nil {
		log.Printf("New PR Title: %q", *newPR.Title)
	} else {
		log.Printf("New PR title is nil")
	}
}

func main() {
	flag.Parse()
	githubSecrets := os.Getenv(envSecret)

	var credentials GithubSecrets
	err := json.Unmarshal([]byte(githubSecrets), &credentials)
	if err != nil {
		log.Fatalf("Failed to unmarshal credentials: %s", err)
		return
	}

	// Set up the auth for being able to talk to Github. It's
	// odd that you have to also pass context around for the
	// calls even after giving it to client. But, whatever.
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: credentials.AccessToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := ghclient.NewClient(tc)

	h := &GithubHandler{
		client: client,
		ctx:    ctx,
	}

	log.Fatal(http.ListenAndServe(":8080", event.Handler(h.newPullRequestPayload)))
}
