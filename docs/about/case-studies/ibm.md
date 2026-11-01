---
hide:
  - toc
audience: buyer
components:
  - eventing
function: marketing
title: IBM Case Study
template: case-study.html
case_study:
  company: IBM
  logo: images/case-studies/ibm.png
  quote: >-
    “We were looking for a solution that would be simple enough to maintain while providing 100% ownership to the service team in all aspects. We prototyped a system in early 2022 using Knative Eventing (backed by Knative Kafka Broker) for our watsonx Assistant use-case. Our initial results exceeded our existing benchmarks at various levels. After investing enough time to make it production ready, we rolled it out across all production IBM cloud clusters in six geographical regions.”
---

## IBM watsonx Assistant uses Knative Eventing to train machine learning models

As IBM’s strategy on cloud evolved and moved towards private and hybrid cloud, solutions such as IBM Cloud Pak for Data and Managed Cloud Service Provider (MCSP) now require highly portable watsonx services capable of running on customer hardware, private infrastructure, and datastore providers that IBM will not have access to. Our existing machine learning training infrastructure, originally designed with a focus on public cloud infrastructure a few years ago, underwent an upgrade to ensure compatibility across various cloud infrastructure solutions. However, as our customer base expanded across these platforms, the associated cost of operations increased. In parallel there was growing pressure to improve the machine learning training time to improve the client experience. Over the course of time, we have heavily optimized our intent recognition algorithms and training infrastructure stack to reduce training time from 3.5 minutes to an impressive 90 seconds. Nevertheless, further optimizations posed challenges, including issues related to resource utilization and backpressure handling in a distributed setup. Recognizing the need for a comprehensive solution, we embarked on a paradigm shift to redefine our entire ML training infrastructure.

## Please read the full case study at CNCF site

- [How IBM watsonx Assistant uses Knative Eventing to train machine learning models](https://www.cncf.io/case-studies/ibmwatsonxassistant/)

## Find out more

- [Getting started with Knative](/docs/getting-started/)
- [Knative Serving](/docs/serving/)
- [Knative Eventing](/docs/eventing/)
