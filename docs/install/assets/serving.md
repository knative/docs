# Knative Serving installation files (0.21 releases)

| File name | Description | Dependencies|
| --- | --- | --- |
| serving-core.yaml | Knative Serving core components. | serving-crds.yaml |
| serving-crds.yaml | Knative Serving core CRDs. | none |
| serving-default-domain.yaml | Configuring Knative Serving to use <a href="http://xip.io">xip.io</a> as the default DNS suffix. | serving-core.yaml |
| serving-domainmapping-crds.yaml | CRDs required by the DomainMapping feature. | none |
| serving-domainmapping.yaml | Componnents required by the DomainMapping feature. | serving-domainmapping-crds.yaml |
| serving-hpa.yaml | Components to auto scale Knative revisions via Kubeneters HPA. | serving-core.yaml |
  serving-nscert.yaml | Components to provision TLS wildcard certificates. | serving-core.yaml |
| serving-post-install-jobs.yaml | Optional jobs after installing serving-core.yaml. Currently it is same to `serving-storage-version-migration.yaml`. | serving-core.yaml |
| serving-storage-version-migration.yaml | Migrating the storage version of Knative resources, including Service, Route, Revision, Configuration, from v1alpha1 & v1beta1 to v1. Required by upgrade from 0.18 to 0.19 version. | serving-core.yaml |
