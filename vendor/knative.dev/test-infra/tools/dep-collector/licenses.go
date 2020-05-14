/*
Copyright 2018 The Knative Authors

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
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/google/licenseclassifier"
)

// Type identifies a class of software license.
type Type string

// License types
const (
	// Unknown license type.
	Unknown = Type("")
	// Restricted licenses require mandatory source distribution if we ship a
	// product that includes third-party code protected by such a license.
	Restricted = Type("restricted")
	// Reciprocal licenses allow usage of software made available under such
	// licenses freely in *unmodified* form. If the third-party source code is
	// modified in any way these modifications to the original third-party
	// source code must be made available.
	Reciprocal = Type("reciprocal")
	// Notice licenses contain few restrictions, allowing original or modified
	// third-party software to be shipped in any product without endangering or
	// encumbering our source code. All of the licenses in this category do,
	// however, have an "original Copyright notice" or "advertising clause",
	// wherein any external distributions must include the notice or clause
	// specified in the license.
	Notice = Type("notice")
	// Permissive licenses are even more lenient than a 'notice' license.
	// Not even a copyright notice is required for license compliance.
	Permissive = Type("permissive")
	// Unencumbered covers licenses that basically declare that the code is "free for any use".
	Unencumbered = Type("unencumbered")
	// Forbidden licenses are forbidden to be used.
	Forbidden = Type("FORBIDDEN")
)

func (t Type) String() string {
	switch t {
	case Unknown:
		// licenseclassifier uses an empty string to indicate an unknown license
		// type, which is unclear to users when printed as a string.
		return "unknown"
	default:
		return string(t)
	}
}

var LicenseNames = []string{
	"LICENCE",
	"LICENSE",
	"LICENSE.code",
	"LICENSE.md",
	"LICENSE.txt",
	"COPYING",
	"copyright",
}

const MatchThreshold = 0.9

type LicenseFile struct {
	EnclosingImportPath string
	LicensePath         string
}

func (lf *LicenseFile) Body() (string, error) {
	body, err := ioutil.ReadFile(lf.LicensePath)
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func (lf *LicenseFile) Classify(classifier *licenseclassifier.License) (string, error) {
	body, err := lf.Body()
	if err != nil {
		return "", err
	}
	m := classifier.NearestMatch(body)
	if m == nil {
		return "", fmt.Errorf("unable to classify license: %v", lf.EnclosingImportPath)
	}
	return m.Name, nil
}

func (lf *LicenseFile) Check(classifier *licenseclassifier.License) error {
	body, err := lf.Body()
	if err != nil {
		return err
	}
	ms := classifier.MultipleMatch(body, false)
	for _, m := range ms {
		return fmt.Errorf("found matching forbidden license in %q: %v", lf.EnclosingImportPath, m.Name)
	}
	return nil
}

func (lf *LicenseFile) Entry() (string, error) {
	body, err := lf.Body()
	if err != nil {
		return "", err
	}
	return fmt.Sprintf(`
===========================================================
Import: %s

%s
`, lf.EnclosingImportPath, body), nil
}

func (lf *LicenseFile) CSVRow(classifier *licenseclassifier.License) (string, error) {
	classification, err := lf.Classify(classifier)
	if err != nil {
		return "", err
	}
	parts := strings.Split(lf.EnclosingImportPath, "/vendor/")
	if len(parts) != 2 {
		return "", fmt.Errorf("wrong number of parts splitting import path on %q : %q", "/vendor/", lf.EnclosingImportPath)
	}
	return strings.Join([]string{
		parts[1],
		"Static",
		"", // TODO(mattmoor): Modifications?
		"https://" + parts[0] + "/blob/master/vendor/" + parts[1] + "/" + filepath.Base(lf.LicensePath),
		classification,
	}, ","), nil
}

func findLicense(ii ImportInfo) (*LicenseFile, error) {
	dir := ii.Dir
	ip := ii.ImportPath
	for {
		// When we reach the root of our workspace, stop searching.
		if dir == WorkingDir {
			return nil, fmt.Errorf("unable to find license for %q", ip)
		}

		for _, name := range LicenseNames {
			p := filepath.Join(dir, name)
			if _, err := os.Stat(p); err != nil {
				continue
			}

			return &LicenseFile{
				EnclosingImportPath: ip,
				LicensePath:         p,
			}, nil
		}

		// Walk to the parent directory / import path
		dir = filepath.Dir(dir)
		ip = filepath.Dir(ip)
	}
}

type LicenseCollection []*LicenseFile

func (lc LicenseCollection) Entries() (string, error) {
	sections := make([]string, 0, len(lc))
	for _, key := range lc {
		entry, err := key.Entry()
		if err != nil {
			return "", err
		}
		sections = append(sections, entry)
	}
	return strings.Join(sections, "\n"), nil
}

func (lc LicenseCollection) CSV(classifier *licenseclassifier.License) (string, error) {
	sections := make([]string, 0, len(lc))
	for _, entry := range lc {
		row, err := entry.CSVRow(classifier)
		if err != nil {
			return "", err
		}
		sections = append(sections, row)
	}
	return strings.Join(sections, "\n"), nil
}

func (lc LicenseCollection) Check(classifier *licenseclassifier.License) error {
	errors := []string{}
	for _, entry := range lc {
		licenseName, licenseType, err := entry.Identify(entry.LicensePath, classifier)
		if err != nil {
			return err
		}
		if licenseType == Forbidden {
			errors = append(errors, fmt.Sprintf("Forbidden license type %s for library %v\n", licenseName, entry))
		}
	}
	if len(errors) == 0 {
		return nil
	}
	return fmt.Errorf("Errors validating licenses:\n%v", strings.Join(errors, "\n"))
}

// Identify returns the name and type of a license, given its file path.
// An empty license path results in an empty name and Unknown type.
func (lf *LicenseFile) Identify(licensePath string, classifier *licenseclassifier.License) (string, Type, error) {
	if licensePath == "" {
		return "", Unknown, nil
	}
	content, err := ioutil.ReadFile(licensePath)
	if err != nil {
		return "", "", err
	}
	matches := classifier.MultipleMatch(string(content), true)
	if len(matches) == 0 {
		return "", "", fmt.Errorf("unknown license")
	}
	licenseName := matches[0].Name
	return licenseName, Type(licenseclassifier.LicenseType(licenseName)), nil
}

// CollectLicenses collects a list of licenses for the given imports.
func CollectLicenses(importInfos []ImportInfo) (LicenseCollection, error) {
	// for each of the import paths, search for a license file.
	licenseFiles := make(map[string]*LicenseFile)
	for _, info := range importInfos {
		lf, err := findLicense(info)
		if err != nil {
			return nil, err
		}
		licenseFiles[lf.EnclosingImportPath] = lf
	}

	order := sort.StringSlice{}
	for key := range licenseFiles {
		order = append(order, key)
	}
	order.Sort()

	licenseTypes := LicenseCollection{}
	for _, key := range order {
		licenseTypes = append(licenseTypes, licenseFiles[key])
	}
	return licenseTypes, nil
}
