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

package sampleconsistency

import (
	"bufio"
	"os"
	"path"
	"strings"
	"testing"

	"github.com/knative/docs/test"
	"github.com/knative/docs/test/sampleapp"
)

const (
	configFile = "../sampleapp/config.yaml"
)

func readlines(t *testing.T, filename string) []string {
	var res []string
	f, err := os.Open(filename)
	if nil != err {
		t.Fatalf("Failed opening file '%s': '%v'", filename, err)
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		res = append(res, scanner.Text())
	}
	if err = scanner.Err(); nil != err {
		t.Fatalf("Failed reading file '%s': '%v'", filename, err)
	}
	return res
}

func normalize(si string) string {
	return strings.Trim(si, " `\t\r\n")
}

func checkContains(t *testing.T, rl []string, src string) {
	sl := readlines(t, src)
	ir := 0
	is := 0
	best := -1
	// Scans rl(README lines) for entire block matching sl(source lines).
	// Pointer ir: keeps on moving no matter what.
	// Pointer is: moves only when there is a line match, otherwise back to 0. A
	//   match is found if pointer is moved to end.
	// best: tracks where the best match is on source lines, it's always one
	//   more line ahead of real match
	for ir < len(rl) && is < len(sl) {
		nr := normalize(rl[ir])
		ns := normalize(sl[is])

		if "" == ns {
			is++
			if is > best { // Consider it a match if it's empty line
				best = is
			}
			continue
		}
		if "" == nr {
			ir++
			continue
		}
		if nr != ns { // Start over if a non-match is found
			is = 0
		} else {
			is++
			if is > best {
				best = is
			}
		}
		ir++
	}

	if best == -1 {
		// missing line is line 0
		best = 0
	}
	if best != len(sl) {
		t.Fatalf("README.md file is missing line %d ('%s') from file '%s'\nAdditional info:\n%s", best, sl[best], src, sampleapp.ActionMsg)
	}
}

func checkDoc(t *testing.T, lc sampleapp.LanguageConfig) {
	readme := path.Join(lc.SrcDir, "README.md")
	rl := readlines(t, readme)
	for _, f := range lc.Copies {
		src := path.Join(lc.SrcDir, f)
		checkContains(t, rl, src)
	}
}

// TestDocSrc checks content of README.md files, and ensures that the real code of the samples
// is properly embedded in the docs.
func TestDocSrc(t *testing.T) {
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
			checkDoc(t, lc)
		})
	}
}
