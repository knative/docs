# Verifying client binaries

Knative ships a number of client (command-line) binaries which are installed and run on
your local machine.  This page describes how to verify that your downloaded binaries
match those of a Knative release.  While many of these steps may be handled by package
installers like `brew`, you can always perform these steps by hand if you are unsure
about the provenance of those binaries.

## Verifying a Binary Signature

### All platforms

Our releases from 1.9 are signed with [cosign](https://docs.sigstore.dev/cosign/overview). You can use the following steps to verify our binaries.

1. Download the files you want, and the `checksums.txt`, `checksum.txt.pem` and `checksums.txt.sig` files from the releases page:
    ```sh
    # this example verifies the 1.10.0 kn cli from the knative/client repository
    wget https://github.com/knative/client/releases/download/knative-v1.10.0/checksums.txt
    wget https://github.com/knative/client/releases/download/knative-v1.10.0/kn-darwin-amd64
    wget https://github.com/knative/client/releases/download/knative-v1.10.0/checksums.txt.sig
    wget https://github.com/knative/client/releases/download/knative-v1.10.0/checksums.txt.pem
    ```
1. Verify the signature:
    ```sh
    cosign verify-blob \
    --certificate-identity=signer@knative-releases.iam.gserviceaccount.com \
    --certificate-oidc-issuer=https://accounts.google.com \
    --cert checksums.txt.pem \
    --signature checksums.txt.sig \
    checksums.txt
    ```
1. If the signature is valid, you can then verify the SHA256 sums match with the downloaded binary:
    ```sh
    sha256sum --ignore-missing -c checksums.txt
    ```

!!! note
    Knative images are signed in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-releases.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`

### Apple macOS

In addition to signing our binaries with `cosign`, we [notarize](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution) our macOS binaries. You can use the `codesign` utility to verify our binaries from 1.9 release. You should expect an output that looks
like this. The expected TeamIdentifier is `7R64489VHL`

```
codesign --verify -d --verbose=2 ~/Downloads/kn-quickstart-darwin-amd64

Executable=/Users/REDACTED/Downloads/kn-quickstart-darwin-amd64
Identifier=kn-quickstart-darwin-amd64
...
Authority=Developer ID Application: Mahamed Ali (7R64489VHL)
Authority=Developer ID Certification Authority
Authority=Apple Root CA
Timestamp=3 Oct 2022 at 22:50:07
...
TeamIdentifier=7R64489VHL
```
