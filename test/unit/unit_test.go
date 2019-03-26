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

package unit

import (
	"bufio"
	"os"
	"path"
	"strings"
	"testing"

	e2etest "github.com/knative/docs/test/e2e"
)

const (
	configFile = "../e2e/config.yaml"
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
	for ir < len(rl) && is < len(sl) {
		nr := normalize(rl[ir])
		ns := normalize(sl[is])

		if "" == ns {
			is++
			if is > best {
				best = is
			}
			continue
		}
		if "" == nr {
			ir++
			continue
		}
		if nr != ns {
			if is == 11 {
				t.Log(nr)
				t.Log(ns)
			}
			is = 0
		} else {
			is++
			if is > best {
				best = is
			}
		}
		ir++
	}
	if is < len(sl) && best < len(sl) && best != -1 {
		// t.Logf("%v", strings.Join(rl, "\n"))
		t.Fatalf("README missing line '%s' '%d' in file '%s'", sl[best], best, src)
	}
}

func checkDoc(t *testing.T, lc e2etest.LanguageConfig) {
	readme := path.Join(lc.SrcDir, "README.md")
	rl := readlines(t, readme)
	for _, f := range lc.Copies {
		src := path.Join(lc.SrcDir, f)
		checkContains(t, rl, src)
	}
}

// TestDocSrc runs all sample apps from different languages
func TestDocSrc(t *testing.T) {
	lcs, err := e2etest.GetConfigs(configFile)
	if nil != err {
		t.Fatalf("Failed reading config file %s: '%v'", configFile, err)
	}

	whitelist := make(map[string]bool)
	if "" != e2etest.Flags.Languages {
		for _, l := range strings.Split(e2etest.Flags.Languages, ",") {
			whitelist[l] = true
		}
	}
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
