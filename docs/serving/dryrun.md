---
audience: developer
components:
  - serving
function: how-to
---

# Performing dry-run validation on service spec
By default, dry-run validation on a service spec is not performed. To perform dry-run on a service or configuration `--dry-run=server` must be specified when applying/creating a resource.

Example:

  ```bash
  kubectl apply -f <service-or-config-spec>.yaml --dry-run=server
  ```


**Note:** This feature used to be enabled using the feature flags `kubernetes.podspec-dryrun` in a configuration and `features.knative.dev/podspec-dryrun` annotation on a service. These have been removed.


