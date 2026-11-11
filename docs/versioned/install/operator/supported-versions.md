---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Operator-supported component versions

This table lists the Serving and Eventing releases bundled with each documented Operator release. The current v1.24 row was checked against the tagged [Serving manifests](https://github.com/knative/operator/tree/knative-v1.24.0/cmd/operator/kodata/knative-serving) and [Eventing manifests](https://github.com/knative/operator/tree/knative-v1.24.0/cmd/operator/kodata/knative-eventing), including their versioned directories and core-manifest component Namespace release labels. The v1.23 row is retained as historical release information.

This is not a Kubernetes compatibility matrix or a support policy for every Knative distribution. For another Operator release, consult its [release information](https://github.com/knative/operator/releases).

| Operator | Serving | Eventing |
| --- | --- | --- |
| v1.24 | v1.24.0<br/>v1.23.0<br/>v1.22.0 and v1.22.1<br/>v1.21.0, v1.21.1, v1.21.2 and v1.21.3 | v1.24.0<br/>v1.23.0 and v1.23.1<br/>v1.22.0, v1.22.1 and v1.22.2<br/>v1.21.0, v1.21.1, v1.21.2, v1.21.3 and v1.21.4 |
| v1.23 | v1.23.0<br/>v1.22.0 and v1.22.1<br/>v1.21.0, v1.21.1, v1.21.2 and v1.21.3<br/>v1.20.0, v1.20.1, v1.20.2 and v1.20.3 | v1.23.0<br/>v1.22.0, v1.22.1 and v1.22.2<br/>v1.21.0, v1.21.1, v1.21.2, v1.21.3 and v1.21.4<br/>v1.20.0, v1.20.1, v1.20.2 and v1.20.3 |

For installation steps, see [Install by using the Knative Operator](knative-with-operators.md). For changing a running installation, follow [Upgrade a Knative installation with the Operator](../upgrade/upgrade-installation-with-operator.md); availability of a version in this table does not make a multi-minor-version upgrade a supported single step.
