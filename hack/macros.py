import os

def define_env(env):

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
            return 'https://storage.googleapis.com/knative-nightly/{repo}/latest/{file}'.format(
                    repo=repo,
                    file=file)
        else:
            return 'https://github.com/{org}/{repo}/releases/download/{version}/{file}'.format(
                    repo=repo,
                    file=file,
                    version=version,
                    org=org)

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
