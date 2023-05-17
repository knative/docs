## Verifying image signatures

Knative releases from 1.9 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview).

1. Install [cosign](https://docs.sigstore.dev/cosign/installation/) and [jq](https://stedolan.github.io/jq/).

1. Extract the images from a manifeset and verify the signatures.

```
curl -sSL https://github.com/knative/serving/releases/download/knative-v1.10.1/serving-core.yaml \
  | grep 'gcr.io/' | awk '{print $2}' | sort | uniq \
  | xargs -n 1 \
    cosign verify -o text \
      --certificate-identity=signer@knative-releases.iam.gserviceaccount.com \
      --certificate-oidc-issuer=https://accounts.google.com
```

!!! note
    Knative images are signed in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-releases.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`
