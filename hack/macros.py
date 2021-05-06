import os

def define_env(env):

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
