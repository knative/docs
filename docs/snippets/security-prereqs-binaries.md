## Verifying Binaries

Knative releases from 1.8 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview).

- **Verifying CLI Binaries**

Knative releases from 1.8 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview). You can use the following steps to verify our binaries.

1. Download the files you want, and the `checksums.txt`, `checksum.txt.pem` and `checksums.txt.sig` files from the releases page:
    ```sh
    # this example verifies the 1.8.0 kn cli from the knative/client repository
    wget https://github.com/knative/client/releases/download/knative-v1.8.0/checksums.txt
    wget https://github.com/knative/client/releases/download/knative-v1.8.0/kn-darwin-amd64
    wget https://github.com/knative/client/releases/download/knative-v1.8.0/checksums.txt.sig
    wget https://github.com/knative/client/releases/download/knative-v1.8.0/checksums.txt.pem
    ```
1. Verify the signature:
    ```sh
    COSIGN_EXPERIMENTAL=1 cosign verify-blob \
    --cert checksums.txt.pem \
    --signature checksums.txt.sig \
    checksums.txt
    ```
1. If the signature is valid, you can then verify the SHA256 sums match with the downloaded binary:
    ```sh
    sha256sum --ignore-missing -c checksums.txt


!!! note
    `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed
    in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-nightly.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`
