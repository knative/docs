# Fuzzing audit results

**Author: [Adam Korczynski](https://twitter.com/AdamKorcz4), Security Engineer @ [Ada Logics](https://adalogics.com/)**

Knative is happy to announce the completion of its fuzzing security audit. The audit was carried out by Ada Logics and is part of an initiative by the CNCF to [bring fuzzing to the CNCF landscape](https://www.cncf.io/blog/2022/06/28/improving-security-by-fuzzing-the-cncf-landscape). The audit spanned several months in late 2022 and early 2023 and resulted in 29 fuzzers written for 3 Knative sub-projects. The fuzzers found a single issue in a 3rd-party dependency that has been fixed.

Read the full report for the audit here: [Knative Fuzzing Report](https://github.com/knative/docs/tree/main/reports/ADA-knative-fuzzing-audit-22-23.pdf).

The audit covered the following three Knative sub-projects:

- [Knative serving](https://github.com/knative/serving)
- [Knative eventing](https://github.com/knative/eventing)
- [Knative pkg](https://github.com/knative/pkg)

## Fuzzing

Fuzzing is a way of testing software, whereby pseudo-random data is passed to a target API to find bugs and security issues. The pseudo-random data is created by a fuzzing engine that, over time will generate test cases that uncover more of the code base. This engine uses a coverage-guided approach and uses the feedback from each iteration to mutate new test cases. This type of fuzzing is called “coverage-guided fuzzing” and has been effective in finding bugs in software projects implemented in both memory-safe and memory-unsafe languages - including several other CNCF-hosted projects; Most recently, fuzzing has found security vulnerabilities in Notation-go and Crossplane during their CNCF-sponsored fuzzing audits. Read more about these here:

- [Crossplane fuzzing audit](https://www.cncf.io/blog/2023/03/24/crossplane-completes-fuzzing-security-audit/)
- [Notary project fuzzing audit](https://www.cncf.io/blog/2023/03/21/the-notary-project-completes-fuzzing-security-audit/)

## Fuzzing Knative

An important component of a robust fuzzing suite is making sure that the fuzzers run continuously. All Knatives fuzzers run continuously on OSS-Fuzz - Googles open source platform for running the fuzzers of critical open source projects continuously with excessive resources. Knatives fuzzing audit started by integrating Knative into OSS-Fuzz, and the auditors then added the fuzzers to that integration. This allowed the fuzzers to run continuously during the audit and will continue to do so after the audit has concluded. 

The fuzzers developed during the audit cover different parts of the Knative ecosystem. These include and are not limited to:

- **Resource validation**: Knatives [validation fuzzer](https://github.com/cncf/cncf-fuzzing/blob/6547f868d30a08f0f9f7d835a84d09f66944bb96/projects/knative/fuzz_validation.go) creates pseudo-randomized resources and tests their validation routines. The fuzzer tests the validation of 23 different resource types.
- **Scheduler plugings**: All of Knative eventings [the scheduler plugins](https://github.com/knative/eventing/tree/main/pkg/scheduler/plugins/core) are covered. 
- **Improved roundtrip fuzzers**: Prior to the fuzzing audit, Knative had fuzz tests to test deserialization of its custom resources. These ran against [Kubernetes’ upstream roundtrip tests](https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/apimachinery/pkg/api/apitesting/roundtrip/roundtrip.go). During the audit, Ada Logics wrote an improved roundtrip test that runs 3,5 times faster than the upstream roundtrip tests and thus allows the fuzzers to explore more code. Knatives roundtrip fuzzers were also not running continuously, and the auditors added the improved roundtrip fuzz tests to Knatives OSS-Fuzz integration.

- **Dependencies**: Knatives fuzzers cover several 3rd-party dependencies that do heavy processing of data coming from Knative.
- **Eventing filters**: The filter fuzzer creates a series of pseudo-random filters and invokes the respective `apply` APIs.

All fuzzers live in CNCF’s fuzzing repository. During OSS-Fuzz’s build cycles, it pulls them from there and runs them against the latest main Knative branches.

## Findings
The fuzzers found a single issue during the audit, which is impressive by the Knative project. The fuzzers continue to explore the target code, and they may find issues in the future. If that happens, OSS-Fuzz will notify the maintainers with a detailed bug report, including a reproducer test case and a stack trace. OSS-Fuzz notifies maintainers via email and automatically marks fixed issues as resolved in OSS-Fuzz’s bug tracker.

## Contributing to Knative
Knative is open source and accepts community contributions. [The community repository](https://github.com/knative/community) is the best place to start if you wish to contribute to the ecosystem. 
