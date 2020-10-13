`install-istio.sh` installs Istio using the Istio Operator.

The profiles are:

- istio-ci-no-mesh.yaml: used in our continuous testing of Knative with Istio
  having sidecar disabled. This is also the setting that we use in our presubmit
  tests.
- istio-ci-mesh.yaml: used in our continuous testing of Knative with Istio
  having sidecar and mTLS enabled.
- istio-minimal.yaml: a minimal Istio installation used for development
  purposes.
