#!/usr/bin/env python3

# Copyright 2026 The Knative Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Print the uv version locked in uv.lock for use by Netlify and Docker."""

from pathlib import Path
import sys
import tomllib


if __name__ == "__main__":
    lockfile = Path(__file__).resolve().parents[1] / "uv.lock"
    with lockfile.open("rb") as file:
        packages = tomllib.load(file).get("package", [])
    versions = [p["version"] for p in packages if p.get("name") == "uv"]
    if len(versions) != 1:
        sys.exit("error: expected exactly one locked uv package in uv.lock")
    print(versions[0])
