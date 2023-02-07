## Verifying CLI binaries

Knative `kn` CLI releases from 1.9 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview). You can use the following steps to verify the CLI binaries:

1. Download the files you want, and the `checksums.txt`, `checksum.txt.pem`, and `checksums.txt.sig` files from the releases page, by running the commands:

    ```sh
    wget https://github.com/knative/client/releases/download/<kn-version>/checksums.txt
    wget https://github.com/knative/client/releases/download/<kn-version>/kn-darwin-amd64
    wget https://github.com/knative/client/releases/download/<kn-version>/checksums.txt.sig
    wget https://github.com/knative/client/releases/download/<kn-version>/checksums.txt.pem
    ```

    Where `<kn-version>` is the version of the CLI that you want to verify. For example, `knative-v1.8.0`.

1. Verify the signature by running the command:

    ```sh
    COSIGN_EXPERIMENTAL=1 cosign verify-blob \
    --cert checksums.txt.pem \
    --signature checksums.txt.sig \
    checksums.txt
    ```

1. If the signature is valid, you can then verify the `SHA256` sums match the downloaded binary, by running the command:

    ```sh
    sha256sum --ignore-missing -c checksums.txt
    ```

!!! note
    `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed in `KEYLESS` mode. To learn more about keyless signing, please refer to [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures). The signing identity for Knative releases is `signer@knative-nightly.iam.gserviceaccount.com`, and the issuer is `https://accounts.google.com`.
