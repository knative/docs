# Serving Encryption Overview

{% include "encryption-notice.md" %}

There are three parts to Knative Serving encryption:

1. HTTPS on the ingress layer _external_ to the cluster (cluster external domain, like `myapp-<namespace>.example.com`).
1. HTTPS on the ingress layer _internal_ to the cluster (cluster local domains, like `myapp.<namespace>.svc.cluster.local`).
1. HTTPS between Knative internal components (`ingress-controller`, `activator`, `queue-proxy`).

![Overview of Knative encryption](./encryption-overview.drawio.svg)

!!! note
    Currently, all control-plane traffic (including Kubernetes PreStopHooks and metadata like metrics) is not encrypted.

## The parts in detail
The different parts are independent of each other and (can) use different Certificate Authorities to sign certificates.

### External domain encryption

![External domain](./encryption-external-domain.drawio.svg)

* Certificate CN/SAN contains the external domain of a Knative Service, e.g. `myapp-<namespace>.example.com`.
* The certificates are hosted using SNI by the external endpoint of the ingress-controller.
* The caller has to trust the (external) CA that signed the certificates (this is out of the scope of Knative).
* These certificates are either provided manually or by enabling automatic certificate provisioning.

See [Configure external domain encryption](./external-domain-tls.md) for more information on this feature.

### Cluster-local encryption

![Cluster local domain](./encryption-cluster-local-domain.drawio.svg)

* Certificate CN/SAN contains the cluster-local domains of a Knative Service, e.g. `myapp.namespace.svc.cluster.local`, `myapp.namespace.svc`, `myapp.namespace`.
* The certificates are hosted using SNI by the cluster-local endpoint of the ingress-controller.
* The caller has to trust the CA that signed the certificates (this is out of the scope of Knative). One option to do this is using [trust-manager](https://cert-manager.io/docs/trust/trust-manager/) from cert-manager.
* To create the certificates, Knative relies on [cert-manager](https://cert-manager.io/) and the Knative cert-manager integration. They need to be installed and configured for the feature to work.

See [Configure cluster-local domain encryption](./cluster-local-domain-tls.md) for more information on this feature.

### Knative system-internal encryption

![Knative system internal](./encryption-system-internal.drawio.svg)

Knative system internal components (Ingress-Controller, Activator, Queue-Proxy) are hosting TLS endpoints when this configuration is enabled.

* To create the certificates, Knative relies on [cert-manager](https://cert-manager.io/) and the Knative cert-manager integration. They need to be installed and configured for the feature to work.
* Specific SANs are used to verify each connection. Each component needs to trust the CA (possibly the full chain) that signed the certificates. For this, Knative system components will consume and trust a provided `CABundle`. The CA bundle needs to be provided by the cluster administrator, possibly using [trust-manager](https://cert-manager.io/docs/trust/trust-manager/) from cert-manager.

See [Configure Knative system-internal encryption](./system-internal-tls.md) for more information on this feature.
