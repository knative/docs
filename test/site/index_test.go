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

// This package contains tests for the layout of the site.

package site

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
)

// TestHugoBundles ensures that all directories with a `README.md` file have
// an appropriate `_index.md` (if a "branch bundle") or `index.md` (if a
// "leaf bundle"). See https://gohugo.io/content-management/page-bundles for
// details on branch and leaf bundles.

func TestHugoBundles(t *testing.T) {
	// We walk the tree relative to the root, not the directory of the test.
	// TODO(evankanderson): find a better way than hard-coding the directory depth.
	err := os.Chdir(filepath.Join("..", ".."))
	if err != nil {
		t.Errorf("Unable to switch to top-level docs directory: %w", err)
	}

	skipNames := []string{"hack", "test", "vendor"}
	skipped := make([]os.FileInfo, len(skipNames))
	for i, s := range skipNames {
		fi, err := os.Stat(s)
		if err != nil {
			t.Errorf("Unable to stat %q: %w", s, err)
		}
		skipped[i] = fi
	}

	err = filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		for _, fi := range skipped {
			if os.SameFile(info, fi) {
				return filepath.SkipDir
			}
		}
		if !info.IsDir() {
			return nil
		}
		_, err = os.Stat(filepath.Join(path, "README.md"))
		if os.IsNotExist(err) {
			return nil
		}
		if err != nil {
			return err // unable to open
		}
		bundleFiles := []string{"_index.md", "index.md", "index.html", "_index.html"}
		for _, name := range bundleFiles {
			_, err = os.Stat(filepath.Join(path, name))
			if err == nil {
				return nil
			}
		}
		return fmt.Errorf("README.md missing bundle (you need an 'index.md' or '_index.md') in %q", path)
	})

	if err != nil {
		t.Errorf("Could not verify docs: %+v", err)
	}
}
