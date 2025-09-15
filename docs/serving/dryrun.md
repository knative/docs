---
audience: developer
components:
  - serving
function: how-to
---

# Validating Resource Using Server-Side Dry Run

Kubernetes dry run lets you ask the API server to admit, default, and validate your object without persisting it to etcd. This is useful to verify that your Knative `Service`, `Configuration`, or `Route` specs are valid and to preview defaults before creating or updating resources.

Use server-side dry run (`--dry-run=server`), which sends the request to the API server with the `dryRun=All` flag. The API server executes admission, defaulting, and validation (including Knative Serving webhooks) but does not persist the object.

What gets validated in server-side dry run

- Knative Serving schema validation for `Service`, `Configuration`, `Route`, and related objects.
- Knative defaulting webhooks apply defaults (for example, missing fields in `spec.template` are defaulted). You can see these defaults with `-o yaml`.
- Kubernetes admission and validation (quotas, RBAC, OpenAPI validation, etc.).

Limitations and notes

- No resources are created or modified. Controllers do not reconcile and no Pods are started.
- External systems are not contacted. For example, image digest resolution by the queue/reconciler and runtime readiness checks do not occur during a dry run.
- Feature gates and validations are the same as for a real request against your current cluster version/configuration.
- Server-side dry run requires a Kubernetes version that supports it (GA since v1.18).

Example

```bash
# Validate the inline manifest above without creating it
kubectl apply --dry-run=server -o yaml -f - <<EOF
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: ghcr.io/knative/helloworld-go:latest
          env:
            - name: TARGET
              value: "Knative"
EOF
```

Troubleshooting

- If server-side dry run fails with validation errors, fix the reported fields in your manifest and retry.
- If you see RBAC errors, ensure your user has permission to create/update the indicated resource kind in the target namespace.

