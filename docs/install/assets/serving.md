# Knative Serving installation files

| File name | Description | Dependencies|
| --- | --- | --- |
| serving-core.yaml | Knative Serving core components. | serving-crds.yaml |
| serving-crds.yaml | Knative Serving core CRDs. | none |
| serving-default-domain.yaml | Configures Knative Serving to use [http://xip.io](xip.io) as the default DNS suffix. | serving-core.yaml |
| serving-domainmapping-crds.yaml | CRDs required by the Domain Mapping feature. | none |
| serving-domainmapping.yaml | Componnents required by the Domain Mapping feature. | serving-domainmapping-crds.yaml |
| serving-hpa.yaml | Components to autoscale Knative revisions through the Kubernetes Horizontal Pod Autoscaler. | serving-core.yaml |
  serving-nscert.yaml | Components to provision TLS wildcard certificates. | serving-core.yaml |
| serving-post-install-jobs.yaml | Optional jobs after installing `serving-core.yaml`. Currently it is the same as `serving-storage-version-migration.yaml`. | serving-core.yaml |
| serving-storage-version-migration.yaml | Migrates the storage version of Knative resources, including Service, Route, Revision, and Configuration, from `v1alpha1` and `v1beta1` to `v1`. Required by upgrade from version 0.18 to 0.19. | serving-core.yaml |
