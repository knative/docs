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
