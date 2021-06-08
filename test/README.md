---
_build:
  render: never
  list: never
---

# Test

This directory contains tests and testing docs.

- [Unit tests](#running-unit-tests) currently reside in the codebase alongside
  the code they test
- [End-to-end tests](#running-end-to-end-tests)

## Running unit tests

TODO(#66): Write real unit tests.

## Running end-to-end tests

### Dependencies

You might need to install `kubetest` in order to run the end-to-end tests
locally:

```bash
go get -u k8s.io/test-infra/kubetest
```

Simply run the `e2e-tests.sh` script, setting `$PROJECT_ID` first to your GCP
project. The script will create a GKE cluster, install Knative, run the
end-to-end tests and delete the cluster.

If you already have a cluster set, ensure that `$PROJECT_ID` is empty and call
the script with the `--run-tests` argument. Note that this requires you to have
Knative Build installed and configured to your particular configuration setup.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
