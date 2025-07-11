---
audience: administrator
components:
  - serving
  - eventing
function: how-to
---

# Verifying Knative Images

Knative publishes SBOMs and SLSA provenance documents for each image in the
Knative release. You can also use this information to configure [the sigstore
policy controller](https://docs.sigstore.dev/policy-controller/overview/) or
other admission controllers to check for these image attestations.

## Prerequisites

You will need to install the [cosign tool](https://github.com/sigstore/cosign/tree/main)
to fetch and interact with the attestations stored in the container registry.

## Knative SLSA Provenance (signed)

The Knative build process produces a SLSA [in-toto](https://in-toto.io/)
attestation for each image in the build process. For a given image in the
Knative release manifests, you can verify the build attestation using the
following:

```bash
cosign verify-attestation \
  --certificate-oidc-issuer https://accounts.google.com \
  --certificate-identity signer@knative-releases.iam.gserviceaccount.com \
  --type slsaprovenance02 \
  $IMAGE
```

!!! note
    Knative images are signed in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-releases.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`

The in-toto document is base64 encoded in the `.payload` attribute
of the attestation; you can use `jq` to extract this with the following
invocation:

```bash
cosign verify-attestation \
  --certificate-oidc-issuer https://accounts.google.com \
  --certificate-identity signer@knative-releases.iam.gserviceaccount.com \
  --type slsaprovenance02 \
  $IMAGE | jq -r .payload | base64 --decode | jq
```

## Knative SBOMs

For each container image, Knative publishes an SBOM corresponding to each
image. These SBOMs are produced during compilation by the
[`ko` tool](https://ko.build/), and can be downloaded using the `cosign download sbom`
command. Note that the image references in the Knative manifests are to
multi-architecture images; to extract the software components for a particular
architecture (as different architectures may build with different libraries),
you will need to run `cosign download sbom` on the architecture-specific image
(e.g. for `linux/amd64`).
