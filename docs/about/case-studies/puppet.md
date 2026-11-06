---
hide:
  - toc
audience: buyer
components:
  - serving
function: marketing
title: Puppet Case Study
template: case-study.html
case_study:
  company: Puppet
  logo: images/case-studies/puppet.png
  quote: >-
    "I'm a strong believer in working with open source projects. We've made contributions to numerous projects, including Tekton, Knative, Ambassador, and gVisor, all of which we depend on to make our product functional"
  attribution: -- Noah Fontes, Senior Principal Software Engineer for Puppet
---

## Relay by Puppet Brings Workflows to Everything using Knative

<a href=https://puppet.com>Puppet</a> is a software company specializing in infrastructure automation. The company was founded in 2009 to solve some of the most complex problems for those who work in operations. Around 2019, the team noticed that cloud operations teams weren’t able to effectively manage modern cloud-native applications because they were relying on manual workflow processes. The group saw an opportunity here to build out a platform to connect events triggered by modern architectures to ensure cloud environments remained secure, compliant, and cost-effective.

This is the story of how <a href=https://puppet.com/products/relay>Relay</a>, a cloud-native workflow automation platform, was created, and how Knative and Kubernetes modernize and super-charge business process automation.

## The glue for DevOps

When Puppet first began exploring the power and flexibility of Knative to trigger their Tekton-based workflow execution engine, they weren't quite sure where their journey was going to take them. Knative offered an attractive feature set, so they began building and experimenting. They wanted to build an event-driven DevOps tool; they weren't interested in building just another continuous integration product. In addition, as they continued to explore, they realized that they wanted something flexible and not tied to just one vertical. Whatever they were building, it was not going to focus on just one market.

As their target came into focus, they realized that the serverless applications and functions enabled by <a href="/docs/serving/">Knative Serving</a> would be perfect for a cloud-based business process automation service. Out of this realization, they built <a href=https://relay.sh>Relay</a>, a cloud workflow automation product that helps Cloud Ops teams solve the integration and eventing issues that arise as organizations adopt multiple clouds and SaaS products alongside legacy solutions.

## Containers and webhooks

Containers and webhooks are key elements in the Relay architecture. Containers allow Puppet to offer a cloud-based solution where businesses can configure and deploy workflows as discrete business units. Since the containers provide self-contained environments, even legacy services and packages can be included. This proved to be an essential feature for business customers. Anything that can be contained in a Docker image, for example, can be part of a Relay workflow.

"We focused on containers because they provide isolation," explains Noah Fontes, Senior Principal Software Engineer for Puppet, "Containers provide discrete units of execution, where users can decrease the maintenance burden of complex systems."


Allowing fully-configurable webhooks gives users the flexibility needed to incorporate business processes of all kinds. With webhooks, Relay can interact with nearly any web-based API to trigger rich, fully featured workflows across third party SaaS products, cloud services, web applications, and even system utilities.

Knative Serving provides important infrastructure for Relay. It allows webhooks and services to scale automatically, <a href="/docs/serving/autoscaling/scale-to-zero/">even down to zero</a>. This allows Relay to support pretty much any integration, including those used by only a small number of users. With autoscaling, those services don't consume resources while they are not being used.

## What is Knative Serving?

Modern cloud-based applications deal with massive scaling challenges through several approaches. At the core of most of these is the use of containers: discrete computing units that run single applications, single services, or even just single functions. This approach is incredibly powerful, allowing services to scale the number of resources they consume as demand dictates.

However, while all of this sounds amazing, it can be difficult to manage and configure. One of the most successful solutions for delivering this advanced architecture is Knative Serving. This framework builds on top of Kubernetes to support the deployment and management of serverless applications, services, and functions. In particular, Knative Services focuses on being easy to configure, deploy, and manage.

## Workflow integrations

The open architecture allows Relay to integrate dozens of different services and platforms into workflows. A look at the <a href="https://github.com/relay-integrations">Relay integrations GitHub page</a> provides a list of these integrations and demonstrates their commitment to the open source community.

"I'm a strong believer in working with open source projects. We've made contributions to numerous projects, including Tekton, Knative, Ambassador, and gVisor, all of which we depend on to make our product functional," says Fontes.

## Results: automated infrastructure management

While Relay's infrastructure runs on the Google Cloud Platform, it is a <a href="https://relay.sh/library/">library of workflows, integrations, steps, and triggers</a> that includes services across all major cloud service providers. Relay customers can integrate across Microsoft Azure, AWS, and Oracle Cloud Infrastructure among others. By combining these integrations with SaaS offerings, it truly is becoming the <a href="https://zapier.com/">Zapier</a> of infrastructure management.

“Our customers have diverse needs for managing their workloads that are often best implemented as web APIs. Our product provides a serverless microservice environment powered by Knative that allows them to build this complex tooling without the management and maintenance overhead of traditional deployment architectures. We pass the cost savings on to them, and everyone is happier," said Fontes.

Building and deploying Relay would not have been possible without the existing infrastructure offered by systems such as Knative and <a href="https://tekton.dev">Tekton</a>. Remarkably, Fontes' team never grew above eight engineers. Once they solidified their plan for Relay, they were able to bring it to production in just three months, says Fontes.

## <em>"Thanks to Knative, getting Relay out the door was easier than we thought it would be."</em> said Noah Fontes, Senior Principal Software Engineer.

Knative aims to make scalable, secure, stateless architectures available quickly by abstracting away the complex details of a Kubernetes installation and enabling developers to focus on what matters.

## Find out more

- [Getting started with Knative](/docs/getting-started/)
- [Knative Serving](/docs/serving/)
- [Knative Eventing](/docs/eventing/)
- [A Basic Introduction to Webhooks](https://www.markheath.net/post/basic-introduction-webhooks)
