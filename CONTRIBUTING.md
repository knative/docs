# Contributing to Knative Documentation

**First off, thanks for taking the time to contribute!**

The following is a set of guidelines for contributing to Knative documentation.
These are just guidelines, not rules. Use your best judgment, and feel free to
propose changes to this document in a pull request.

## Before you get started

### Code of Conduct

Knative follows the [Knative Code of Conduct](code-of-conduct.md). By
participating, you are expected to uphold this code. Please report unacceptable
behavior to knative-code-of-conduct@googlegroups.com.

## Contributing to Documentation

### Reporting Documentation Issues

Knative uses github issues to track documentation issues and requests. If you
see a documentation issue, submit an issue using the following steps:

1. Check the [Knative docs issues list](https://github.com/knative/docs/issues)
   as you might find out the issue is a duplicate.
2. Use the [included template for every new issue](https://github.com/knative/docs/issues/new).
   When you create a bug report, include as many details as possible and include
   suggested fixes to the issue.

Note that code issues should be filed against the individual Knative repositories,
while documentation issues should go in the `docs` repository.

### Put your docs in the right place

Knative uses the [docs repository](https://github.com/knative/docs) for all
general documentation for Knative components. However, formal specifications
or documentation most relevant to contributors of a component should be placed
in the `docs` folder within a given component's repository. An example of this
is the [spec](https://github.com/knative/serving/tree/master/docs/spec)
folder within the Serving component.

Code samples follow a similar strategy, where most code samples should be located
in the `docs` repository. If there are code examples or samples used for testing
that are not expected to be used by non-contributors, those samples can be put
in a `samples` folder within the component repo.

### Submitting Documentation Pull Requests

If you're fixing an issue in the existing documentation, you should submit a
PR against the master branch.