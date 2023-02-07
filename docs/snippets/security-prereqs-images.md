## Verifying image signatures

Knative releases from 1.9 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview).

1. Install [cosign](https://docs.sigstore.dev/cosign/installation/) and [jq](https://stedolan.github.io/jq/).

1. Extract the images from a manifeset and verify the signatures.

```
# download the yaml file, this example uses the serving manifest
curl -fsSLO https://github.com/knative/serving/releases/download/knative-v1.9.0/serving-core.yaml
cat serving-core.yaml | grep 'gcr.io/' | awk '{print $2}' > images.txt
input=images.txt
while IFS= read -r image
do
  COSIGN_EXPERIMENTAL=1 cosign verify -o text "$image" | jq
done < "$input"

```

!!! note
    `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed
    in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-nightly.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`
