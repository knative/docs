import os

def define_env(env):

    @env.macro
    def feature(alpha="", beta="", stable=""):
        versions = []
        if alpha != "":
            versions.append('<abbr class="feature-alpha" title="Alpha features are experimental, and may change or be removed without notice">alpha</abbr> since Knative v{version}'.format(version=alpha))
        if beta != "":
            versions.append('<abbr class="feature-beta" title="Beta features are well-tested and enabling them is considered safe. Support for the overall feature will not be dropped, though details may change in incompatible ways">beta</abbr> since Knative v{version}'.format(version=beta))
        if stable != "":
            versions.append('<abbr class="feature-stable" title="Stable features will be maintained for many future versions">stable</abbr> since Knative v{version}'.format(version=stable))
        return '!!! info "Feature Availability: ' + ', '.join(versions) + '"'

    @env.macro
    def artifact(repo, file, org="knative"):
        """Generates a download link for the current release version.

        When the version in the KNATIVE_VERSION environment variable is
        empty this links to googlestorage, otherwise it links via
        the matching release in github.
        """
        version = os.environ.get("KNATIVE_VERSION")
        if version == None:
            return 'https://storage.googleapis.com/{org}-nightly/{repo}/latest/{file}'.format(
                    repo=repo,
                    file=file,
                    org=org)
        else:
            return 'https://github.com/{org}/{repo}/releases/download/{version}/{file}'.format(
                    repo=repo,
                    file=file,
                    version=version,
                    org=org)
