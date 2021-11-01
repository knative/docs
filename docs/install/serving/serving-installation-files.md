# Knative Serving installation files

This guide provides reference information about the core Knative Serving YAML files, including:

- The custom resource definitions (CRDs) and core components required to install Knative Serving.
- Optional components that you can apply to customize your installation.

For information about installing these files, see [Installing Knative Serving using YAML files](install-serving-with-yaml.md).

The following table describes the installation files included in Knative Serving:

| File name | Description | Dependencies|
| --- | --- | --- |
| serving-core.yaml | Required: Knative Serving core components. | serving-crds.yaml |
| serving-crds.yaml | Required: Knative Serving core CRDs. | none |
| serving-default-domain.yaml | Configures Knative Serving to use [http://sslip.io](http://sslip.io) as the default DNS suffix. | serving-core.yaml |
| serving-hpa.yaml | Components to autoscale Knative revisions through the Kubernetes Horizontal Pod Autoscaler. | serving-core.yaml |
| serving-post-install-jobs.yaml | Additional jobs after installing `serving-core.yaml`. Currently it is the same as `serving-storage-version-migration.yaml`. | serving-core.yaml |
| serving-storage-version-migration.yaml | Migrates the storage version of Knative resources, including Service, Route, Revision, and Configuration, from `v1alpha1` and `v1beta1` to `v1`. Required by upgrade from version 0.18 to 0.19. | serving-core.yaml |
