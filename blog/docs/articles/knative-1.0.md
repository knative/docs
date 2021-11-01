---
title: "Knative 1.0 is out!"
linkTitle: "Knative 1.0 is out!"
date: 2021-11-02
description: "Details on the 1.0 release of Knative"
type: "blog"
---

![1.0 Banner Image](/blog/images/1.0Banner.jpg)

***Authors: Carlos Santana (IBM), Omer Bensaadon (VMware), Maria Cruz (Google)***

Today we release Knative 1.0, reaching an important milestone made possible thanks to the contributions and collaboration of over 600 developers. The Knative project was released by Google in July 2018, and it was developed in close partnership with VMWare, IBM, Red Hat, and SAP. Over the last 3 years, Knative has become [the most widely-installed serverless layer on Kubernetes.](https://www.cncf.io/wp-content/uploads/2020/11/CNCF_Survey_Report_2020.pdf)


## What's new

In case you haven't been following Knative's development closely, there have been a lot of changes since our initial release in July 2018.

In addition to a myriad of bug fixes, stability and performance enhancements, our community has shipped the following improvements, in approximately chronological order:

* Support for multiple HTTP routing layers beyond Istio (Contour, Kourier, Ambassador have all implemented this layer)
* Support for multiple storage layers for Eventing concepts with common Subscription methods (implemented by Kafka, GCP PubSub, and RabbitMQ).
* Designed a “Duck types” abstraction to allow processing arbitrary Kubernetes resources that have common fields (like status.conditions and status.address).
* A command-line client with support for additional feature plugins
* Moved from an ad-hoc release process to an every 6 week process
* Support for HTTP2, grpc, and websockets
* Introduced Brokers and Triggers to simplify publishing and subscribing to events while decoupling producers and consumers
* Support for Eventing components delivering to non-Knative components, including off-cluster components or specific URLs on a host.
* Support for automatic provisioning of TLS certificates (either via DNS or HTTP01 challenges)
* Eventing supports customizing delivery options for event destinations, including retries and dead-letter queues for undeliverable messages
* Event tracing support for both Brokers and Channels for improved debugging
* Spawned the Tekton project from Knative Build
* Added Parallel and Sequence components to codify certain composite eventing workflows.
* Documented and cataloged Event Sources and how to contribute them (currently covering about 40 different event sources)
* Tested “hitless” upgrades with no dropped requests between minor version releases
* Redesigned API shapes for Serving to match PodTemplateSpec used by Deployment, CronJob, etc to simplify usage for Kubernetes-aware users
* Added support for injecting event destination addresses into PodTemplateSpec shaped objects
* Support for HPA autoscaling as well as Knative Pod Autoscaling based on concurrency or rps.
* High availability of control plane components using leader election slices
* Added an operator to help administrators install Knative
* Added a quickstart for developer try Knative locally
* Simplified management and publication of Services using DomainMapping (beta)

## Get Involved!
Join the Knative community meetup on November 17, 2021, to hear from Knative maintainer Ville Aikas about the latest changes coming with Knative 1.0. Newcomers to the Knative community are always welcome! Join the Knative Slack space to ask questions and troubleshoot issues as you get acquainted with the project. Finally, find all the project documentation on the Knative website and contribute to the project on GitHub.

Thank you to our contributors!
Achieving this milestone has truly been a community effort, we’d be remiss not to thank some of the people who helped us get here.
Thanks to…

* Knative Supporting Companies
  * Google
  * IBM
  * Red Hat
  * SAP
  * TriggerMesh
  * VMware
  * [And many more](https://knative.teststats.cncf.io/d/5/companies-table?orgId=1&var-period_name=Last%202%20years&var-metric=contributions)
* The Knative Technical Oversight Committee
* The Knative Steering Committee
* The Knative Trademark Committee
* All Knative Contributors, past and present
* Google for sponsoring our website, testing infrastructure and producing the community meetup every month.

---

**Only read past this point if you're curious about the reasoning about the release mechanics; there's no actionable information below.**

* Knative is composed of many components that are versioned together.
* Those components have different levels of maturity, ranging from already-GA to experimental.
* We still want to keep the versions in sync and decided to go for 1.0 for all components.
* GA levels are marked for components individually.

??? question "Why number all components 1.0?""
    Two reasons, one user-facing and one contributor-facing. The big user-facing reason is that it gives users a single number to hang on to when understanding what they've installed and what works together. The smaller contributor-facing reason is that all our infrastructure is designed to manage a single version number, and updating it to support multiple version numbers doesn't seem like a good use of time given the first point.

??? question "Isn't "1.0 and Beta" for a component like eventing-rabbitmq or eventing-kafka-broker confusing?""
    Unless we wait for everything related to Knative to be done, we'll always have some components or features that are in an alpha or beta state. While this sometimes happens along a component boundary, it can also happen within a component, so the version number can't be a sole indicator of "GA or not". (This happens to other projects like Kubernetes as well, and to specific features in Serving or Eventing.)

    Going forward, one of the things we'll need to be clear about is the maturity level of various components or features, and moving features along the path to either GA or retirement.
