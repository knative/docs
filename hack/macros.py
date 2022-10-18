# Copyright 2021 The Knative Authors
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

import os
import semver
import sys
import traceback

from github import Github

# By default mkdocs swallows print() messages from macros
def print_to_stdout(*vargs):
    print(*vargs, file = sys.stdout)

def removeprefix(s, prefix):
    if s.startswith(prefix):
        return s[len(prefix):]
    else:
        return s[:]

def drop_prefix(tag):
    tag = removeprefix(tag, "knative-")
    tag = removeprefix(tag, "v")
    return tag

def is_major_minor(tag, version):
    tag = drop_prefix(tag)
    return tag.startswith(f'{version.major}.{version.minor}')

def safe_semver_parse(tag):
    tag = drop_prefix(tag)
    try:
        return semver.VersionInfo.parse(tag)
    except:
        # If the tag isn't semver
        return semver.VersionInfo.parse('0.0.0')

class GithubReleases:
    def __init__(self):
        self.tags_for_repo = {}
        self.client = Github(os.getenv("GITHUB_TOKEN"))

    def __get_latest(self, version, org, repo):
        key = f'{org}/{repo}'

        if key not in self.tags_for_repo:
            tags = []
            for release in self.client.get_repo(key, lazy=True).get_releases():
                tags.append(release.tag_name)

            tags.sort(key=safe_semver_parse, reverse=True)
            self.tags_for_repo[key] = tags

        tags = self.tags_for_repo[key]
        tags = list(filter(lambda tag: is_major_minor(tag, version), tags))

        if len(tags) > 0:
            return tags[0]
        else:
            return None

    def get_latest_tag(self, version, org, repo):
        tag = self.__get_latest(version, org, repo)

        if tag is not None:
            return tag

        # Try the go.mod tag format 'v0.x.y' if v1.x.y doesn't work
        # knative-v1.0.0 = v0.27.0
        version = version.replace(major=version.major-1, minor=version.minor+27)
        return self.__get_latest(version, org, repo)


def define_env(env):
    releases = GithubReleases()

    @env.macro
    def feature(alpha="", beta="", stable=""):
        versions = []
        descriptions = []
        if alpha != "":
            versions.append('<span class="feature-alpha">alpha</span> since Knative v{version}'.format(version=alpha))
            descriptions.append('    - <span class="feature-alpha">alpha</span> features are experimental, and may change or be removed without notice.')
        if beta != "":
            versions.append('<span class="feature-beta">beta</span> since Knative v{version}'.format(version=beta))
            descriptions.append('    - <span class="feature-beta">beta</span> features are well-tested and enabling them is considered safe. Support for the overall feature will not be dropped, though details may change in incompatible ways.')
        if stable != "":
            versions.append('<span class="feature-stable">stable</span> since Knative v{version}'.format(version=stable))
            descriptions.append('    - <span class="feature-stable">stable</span> features will be maintained for many future versions.')
        return '??? info "Feature Availability: ' + ', '.join(versions) + '"\n' + '\n'.join(descriptions)

    @env.macro
    def artifact(repo, file, org="knative"):
        """Generates a download link for the current release version.

        When the version in the KNATIVE_VERSION environment variable is
        empty this links to googlestorage, otherwise it links via
        the matching release in github.
        """

        version = os.environ.get("KNATIVE_VERSION")

        if version == None:
            return f'https://storage.googleapis.com/knative-nightly/{repo}/latest/{file}'

        version = drop_prefix(version)

        try:
            v = semver.VersionInfo.parse(version)
            latest_version_tag = releases.get_latest_tag(v, org, repo)

            if latest_version_tag is None:
                print_to_stdout(f'repo "{org}/{repo}" has no tags for version "{version}" using latest release for file "{file}"')
                return f'https://github.com/{org}/{repo}/releases/latest/download/{file}'
            else:
                return f'https://github.com/{org}/{repo}/releases/download/{latest_version_tag}/{file}'
        except:
            # We use sys.exit(1) otherwise the mkdocs build doesn't
            # fail on exceptions in macros
            print_to_stdout(f'exception raised for {org}/{repo}/{file}\n', traceback.format_exc())
            sys.exit(1)

    @env.macro
    def clientdocs():
        """Generates a link to the client docs for the current release version.

        When the version in the SAMPLES_BRANCH environment variable is
        empty this links to the main branch, otherwise it links to the
        matching release in Github.
        """
        version = os.environ.get("SAMPLES_BRANCH")
        if version is None:
            return 'https://github.com/knative/client/blob/main/docs/cmd/kn.md'
        return 'https://github.com/knative/client/blob/{version}/docs/cmd/kn.md'.format(version=version)

    @env.macro
    def funcdocs():
        """Generates a link to the func docs for the current release version.
        When the version in the SAMPLES_BRANCH environment variable is
        empty this links to the main branch, otherwise it links to the
        matching release in Github.
        """
        version = os.environ.get("SAMPLES_BRANCH")
        if version is None:
            return 'https://github.com/knative/func/blob/main/docs/reference/func.md'
        return 'https://github.com/knative/func/blob/{version}/docs/reference/func.md'.format(version=version)
