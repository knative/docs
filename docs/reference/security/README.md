# Knative Security and Disclosure Information

This page describes Knative security and disclosure information.

## Knative threat model

* [Threat model](https://github.com/knative/community/blob/main/working-groups/security/threat-model.md)

## Code Signature Verification

### All platforms

Our releases from 1.9 are signed with [cosign](https://docs.sigstore.dev/cosign/overview). You can use the following steps to verify our binaries.

1. Download the files you want, and the `checksums.txt`, `checksum.txt.pem` and `checksums.txt.sig` files from the releases page:
    ```sh
    # this example verifies the 1.9.0 kn cli from the knative/client repository
    wget https://github.com/knative/client/releases/download/knative-v1.9.0/checksums.txt
    wget https://github.com/knative/client/releases/download/knative-v1.9.0/kn-darwin-amd64
    wget https://github.com/knative/client/releases/download/knative-v1.9.0/checksums.txt.sig
    wget https://github.com/knative/client/releases/download/knative-v1.9.0/checksums.txt.pem
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
    ```

!!! note
    `COSIGN_EXPERIMENTAL=1` is used to allow verification of images signed
    in `KEYLESS` mode. To learn more about keyless signing, please refer to
    [Keyless Signatures](https://github.com/sigstore/cosign/blob/main/KEYLESS.md#keyless-signatures)
    Our signing identity(Subject) for our releases is `signer@knative-nightly.iam.gserviceaccount.com` and the Issuer is `https://accounts.google.com`

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

## Report a vulnerability

We're extremely grateful for security researchers and users that report vulnerabilities to the Knative Open Source Community. All reports are thoroughly investigated by a set of community volunteers.

To make a report, please email the private [security@knative.team](mailto:security@knative.team) list with the security details and the details expected for all Knative bug reports.

### When Should I Report a Vulnerability?

* You think you discovered a potential security vulnerability in Knative
* You are unsure how a vulnerability affects Knative
* You think you discovered a vulnerability in another project that Knative depends on
    * For projects with their own vulnerability reporting and disclosure process, please report it directly there

### When Should I NOT Report a Vulnerability?

* You need help tuning Knative components for security
* You need help applying security related updates
* Your issue is not security related

## Vulnerability response

* [Early disclosure of security vulnerabilities](https://github.com/knative/community/blob/main/working-groups/security/disclosure.md)
* [Vulnerability disclosure response policy](https://github.com/knative/community/blob/main/working-groups/security/responding.md)

## Security working group

* [General information](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md#security)
* [Security Working Group Charter](https://github.com/knative/community/blob/main/working-groups/security/CHARTER.md)

