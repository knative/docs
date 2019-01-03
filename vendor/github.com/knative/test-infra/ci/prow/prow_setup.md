# Prow setup

## Creating the cluster

1. Create the GKE cluster, the role bindings and the GitHub secrets. You might need to update [Makefile](./Makefile). For details, see https://github.com/kubernetes/test-infra/blob/master/prow/getting_started.md.

1. Ensure the GCP projects listed in [resources.yaml](./boskos/resources.yaml) are created.

1. Apply [config_start.yaml](./config_start.yaml) to the cluster.

1. Apply Boskos [config_start.yaml](./boskos/config_start.yaml) to the cluster.

1. Run `make update-cluster`, `make update-boskos`, `make update-config`, `make update-plugins` and `make update-boskos-config`.

1. If SSL needs to be reconfigured, promote your ingress IP to static in Cloud Console, and [create the TLS secret](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls).

## Expanding Boskos pool

1. Create a new GCP project and add it to [resources.yaml](./boskos/resources.yaml).

1. Make `knative-tests@appspot.gserviceaccount.com` an editor of the project.

1. Enable the Compute Engine API for the project (e.g., by visiting https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=XXXXXXXX).

1. Enable the Kubernetes Engine API for the project (e.g., by visiting https://console.cloud.google.com/apis/api/container.googleapis.com/overview?project=XXXXXXXX).

1. Run `make update-boskos-config`.

## Setting up Prow for a new repo

1. Create the appropriate `OWNERS` files (at least one for the root dir).

1. Make sure that *Knative Robots* is an Admin of the repo.

1. Update the tide section in the Prow config file and run `make update-config` (ask one of the owners of knative/test-infra).

1. Wait a few minutes, check that Prow is working by entering `/woof` as a comment in any PR in the new repo.

1. Set **tide** as a required status check for the master branch.

### Setting up jobs for a new repo 

1. Have the test infrastructure in place (usually this means having at least `//test/presubmit-tests.sh` working, and optionally `//hack/release.sh` working for automated nightly releases).

1. Merge a pull request (e.g., https://github.com/knative/test-infra/pull/203) that:

   1. Updates the Prow config file (usually, copy and update existing jobs from another repository).
   
      1. For the presubmit tests, setup the *pull-knative-**repo**-**(build|unit|integration)**-tests* jobs.

      1. For go test coverage, setup the ***(pull|post|ci)**-knative-**repo**-go-coverage* jobs.

      1. For the continuous integration tests, setup the *ci-knative-**repo**-continuous* job.

      1. For automated nightly releases, setup the *ci-knative-**repo**-release* job.

    1. Updates the Gubernator config with the new log dirs.

    1. Updates the Testgrid config with the new buckets, tabs and dashboard.

1. Ask one of the owners of *knative/test-infra* to:

    1. Run `make update-config` in `ci/prow`.

    1. Run `make deploy` in `ci/gubernator`.

    1. Run `make update-config` in `ci/testgrid`.

1. Wait a few minutes, enter `/retest` as a comment in any PR in the repo and ensure the test jobs are executed.

1. Set the new test jobs as required status checks for the master branch.
