# Knative Completes Third-Party Security Audit

**Author: [Adam Korczynski](https://twitter.com/AdamKorcz4), Security Engineer @ [Ada Logics](https://adalogics.com/)**

Knative is happy to announce the completion of its third-party security audit conducted by [Ada Logics](https://adalogics.com/) and facilitated by the [Open Source Technology Improvement Fund](https://ostif.org/). This is Knative’s second third-party security audit in just a few months. In July this year, Knative completed a fuzzing security audit also conducted by Ada Logics. While the fuzzing security audit focused on improving the state of fuzzing Knative in an automated manner, today Knative completed an audit that focused on threat modelling, manual code auditing and a supply-chain risk assessment. 

During the audit, Ada Logics was in close communication with the Knative team and shared findings ad hoc as the audit progressed. The Knative team and Ada Logics collaborated on mitigation and fixes of the issues found. 

The audit mainly focused on the three core Knative subprojects: Eventing, Serving and Pkg, with a minor focus on Knative Extensions, Knative Func and Security-Guard.

Knative Extensions are optional plugins and extensions for different Knative use cases. For example, users can find different officially maintained integrations for Knative Eventing, and the Security-Guard project also resides in Knative Extensions. Many Knative Extensions subprojects are not fully mature yet, with many having Alpha and Beta release statuses. 

Ada Logics found 16 security issues of which all except for one have been fixed with upstream patches. Three of the found issues are in third-party dependencies to Knative. One of the issues found is scored with high severity due to its potential impact (ADA-KNATIVE-23-7). However, an attacker would need to compromise the Knative user’s supply-chain, which is highly unlikely to occur in a real-world scenario because few Knative users consume Knative in a way that would enable the attack. In addition, the attacker would need to time their attack to a high degree. The issue has been fixed.

One CVE was assigned during the audit for a vulnerability that could allow an attacker with already escalated privileges to cause further damage in the cluster. The attacker needs to first establish a position in a Knative pod, and from there, they could exploit the vulnerability and cause denial of service of the Knative autoscaling, thereby denying any autoscaling of Knative. The issue was assigned CVE-2023-48713 of Moderate severity and has been fixed in v1.12.0, v1.11.3 and v1.10.5.

Prior to the audit, Knative had invested in building its own [provenance generator](https://github.com/knative/toolbox/tree/main/provenance-generator) which generates slsa-compliant provenance and adds it to releases. Users can verify the provenance using [the official SLSA guidelines](https://slsa.dev/spec/v1.0/verifying-artifacts) before consuming. The Knative maintainers found that Knative Serving was missing a few lines of Prow configuration which resulted in Knative Serving releases not having provenance. This was fixed [here](https://github.com/knative/infra/pull/288) which ensures that future releases of Knative Serving will include verifiable provenance.

Knative would like to thank Ada Logics for conducting the security audit, OSTIF for facilitating it and the CNCF for funding the audit.

Knative is an open-source project that encourages community contributions. If you wish to contribute to Knative’s ongoing security work, we recommend that you read through the report, in particular the strategic recommendations and the SAST tooling section, which both include practical recommendations for Knative’s security posture. If you have questions, comments or suggestions, you can [engage with the community in several ways](https://knative.dev/docs/community/).

- [Audit report](https://github.com/knative/docs/blob/main/reports/ADA-knative-security-audit-2023.pdf)
