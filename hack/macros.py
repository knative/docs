import os
import semver
import sys
import traceback

from github import Github

# By default mkdocs swallows print() messages from macros
def print_to_stdout(*vargs):
    print(*vargs, file = sys.stdout)

class GithubReleases:
    def __init__(self):
        self.tags_for_repo = {}
        self.g = Github(os.getenv("GITHUB_TOKEN"))

    def latest_release(self, major_minor, org, repo):
        key = f'{org}/{repo}'

        if key not in self.tags_for_repo:
            tags = []
            for release in self.g.get_repo(key, lazy=True).get_releases():
                tags.append(release.tag_name)
            tags = map(lambda tag: tag.removeprefix("knative-v"), tags)
            self.tags_for_repo[key] = list(tags)

        tags = self.tags_for_repo[key].copy()
        tags = list(filter(lambda tag: tag.startswith(major_minor), tags))
        tags.sort(key=semver.VersionInfo.parse, reverse=True)

        if len(tags) > 0:
            return tags[0]
        else:
            return None

def define_env(env):
    g = GithubReleases()

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

        version = version.removeprefix('v')

        try:
            v = semver.VersionInfo.parse(version)
            latest_version = g.latest_release(f'{v.major}.{v.minor}', org, repo)

            if latest_version is None:
                print_to_stdout(f'repo "{org}/{repo}" has no tags using latest release for file "{file}"')
                return f'https://github.com/{org}/{repo}/releases/latest/download/{file}'
            elif version.startswith("1."):
                return f'https://github.com/{org}/{repo}/releases/download/knative-v{latest_version}/{file}'
            else:
                return f'https://github.com/{org}/{repo}/releases/download/{latest_version}/{file}'
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
