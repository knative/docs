# Development

This doc explains how to setup a development environment so you can get started
[contributing](https://www.knative.dev/contributing/) to `Knative Docs`. Also
take a look at:

- [The pull request workflow](https://www.knative.dev/contributing/contributing/#pull-requests)

## Prerequisites

Follow the instructions below to set up your development environment. Once you
meet these requirements, you can make changes and

Before submitting a PR, see also [CONTRIBUTING.md](./CONTRIBUTING.md).

### Sign up for GitHub

Start by creating [a GitHub account](https://github.com/join), then setup
[GitHub access via SSH](https://help.github.com/articles/connecting-to-github-with-ssh/).

### Install requirements

### Setup your environment

### Checkout your fork

The Go tools require that you clone the repository to the
`src/knative.dev/serving` directory in your
[`GOPATH`](https://github.com/golang/go/wiki/SettingGOPATH).

To check out this repository:

1. Create your own
   [fork of this repo](https://help.github.com/articles/fork-a-repo/)
1. Clone it to your machine:

```shell
mkdir -p ${GOPATH}/src/knative.dev
cd ${GOPATH}/src/knative.dev
git clone git@github.com:${YOUR_GITHUB_USERNAME}/docs.git
cd docs
git remote add upstream https://github.com/knative/docs.git
git remote set-url --push upstream no_push
```

_Adding the `upstream` remote sets you up nicely for regularly
[syncing your fork](https://help.github.com/articles/syncing-a-fork/)._

### Common Troubleshooting issues for PRs

1. The CLA check fails even though you have signed the CLA. This may occur if you accept and commit suggestions in a pull request from another person's account, because the email address of that account doesn't match the address on record for the CLA.

1. One or more tests are failing. If you do not see a specific error related to a change you made, and instead the errors are related to timeouts, try rerunning the test at a later time. There are running tasks that could result in timeouts or rate limiting if your test runs at the same time.

1. Previews are not working - WIP (not sure what's causing this)

1. Other Issues/Unsure - reach out in the #docs slack channel and someone will be happy to help out.
