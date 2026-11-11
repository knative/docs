---
audience: developer
components:
  - functions
  - serving
  - eventing
# Landing page: security tasks, threat model, and disclosure policy.
---

# Knative Security and Disclosure Information

Use this page to choose security guidance or find the private vulnerability reporting process. Installing Knative or verifying an artifact does not by itself establish a secure deployment.

## Choose security guidance

- **Understand the trust boundaries:** [Knative threat model](threat-model.md), including infrastructure assumptions and mitigations.
- **Verify release artifacts:** [verify client binaries](verifying-cli.md) or [verify images and provenance](verifying-images.md).
- **Configure an installation:** [administrator isolation guidance](../../admin/admin-overview.md#securing-knative) and [Serving encryption guidance](../../serving/encryption/encryption-overview.md).
- **Report a suspected vulnerability:** use the private process below, not a public issue containing security details.

## Reporting a Vulnerability

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

