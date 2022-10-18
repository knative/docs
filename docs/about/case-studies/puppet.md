---
hide:
  - toc
---
<h1 style="color:#0071c7;font-size: 3em;">Puppet Case Study</h1>
<table style="border: 0;">
<tr style="background-color: var(--md-default-bg-color);">
<td style="border: 0;">
<div style="min-width: 20mm;">
      <img src="../../../images/case-studies/puppet.png" alt="" draggable="false" />
</div>
<div>
<em style="color:#0071c7;font-size: 1em;">"I'm a strong believer in working with open source projects. We've made contributions to numerous projects, including Tekton, Knative, Ambassador, and gVisor, all of which we depend on to make our product functional"</em>
</div>
<div>
<p style="color:#0071c7;font-size: 1em;">-- Noah Fontes, Senior Principal Software Engineer for Puppet</p>
</div>

</td>

<td style="border: 0;">

<h2 style="font-weight: bold;">Relay by Puppet Brings Workflows to Everything using Knative</h2>

<a href=https://puppet.com>Puppet</a> is a software company specializing in infrastructure automation. The company was founded in 2009 to solve some of the most complex problems for those who work in operations. Around 2019, the team noticed that cloud operations teams weren’t able to effectively manage modern cloud-native applications because they were relying on manual workflow processes. The group saw an opportunity here to build out a platform to connect events triggered by modern architectures to ensure cloud environments remained secure, compliant, and cost-effective.

This is the story of how <a href=https://puppet.com/products/relay>Relay</a>, a cloud-native workflow automation platform, was created, and how Knative and Kubernetes modernize and super-charge business process automation.

<h2 style="color:#0071c7;"> The glue for DevOps</h2>

When Puppet first began exploring the power and flexibility of Knative to trigger their Tekton-based workflow execution engine, they weren't quite sure where their journey was going to take them. Knative offered an attractive feature set, so they began building and experimenting. They wanted to build an event-driven DevOps tool; they weren't interested in building just another continuous integration product. In addition, as they continued to explore, they realized that they wanted something flexible and not tied to just one vertical. Whatever they were building, it was not going to focus on just one market.

As their target came into focus, they realized that the serverless applications and functions enabled by <a href="../../../serving/">Knative Serving</a> would be perfect for a cloud-based business process automation service. Out of this realization, they built <a href=https://relay.sh>Relay</a>, a cloud workflow automation product that helps Cloud Ops teams solve the integration and eventing issues that arise as organizations adopt multiple clouds and SaaS products alongside legacy solutions.

<h2 style="color:#0071c7;"> Containers and webhooks</h2>

Containers and webhooks are key elements in the Relay architecture. Containers allow Puppet to offer a cloud-based solution where businesses can configure and deploy workflows as discrete business units. Since the containers provide self-contained environments, even legacy services and packages can be included. This proved to be an essential feature for business customers. Anything that can be contained in a Docker image, for example, can be part of a Relay workflow.

"We focused on containers because they provide isolation," explains Noah Fontes, Senior Principal Software Engineer for Puppet, "Containers provide discrete units of execution, where users can decrease the maintenance burden of complex systems."


Allowing fully-configurable webhooks gives users the flexibility needed to incorporate business processes of all kinds. With webhooks, Relay can interact with nearly any web-based API to trigger rich, fully featured workflows across third party SaaS products, cloud services, web applications, and even system utilities.

Knative Serving provides important infrastructure for Relay. It allows webhooks and services to scale automatically, <a href="../../../serving/autoscaling/scale-to-zero/">even down to zero</a>. This allows Relay to support pretty much any integration, including those used by only a small number of users. With autoscaling, those services don't consume resources while they are not being used.

<h2 style="color:#0071c7;"> What is Knative Serving?</h2>

Modern cloud-based applications deal with massive scaling challenges through several approaches. At the core of most of these is the use of containers: discrete computing units that run single applications, single services, or even just single functions. This approach is incredibly powerful, allowing services to scale the number of resources they consume as demand dictates.

However, while all of this sounds amazing, it can be difficult to manage and configure. One of the most successful solutions for delivering this advanced architecture is Knative Serving. This framework builds on top of Kubernetes to support the deployment and management of serverless applications, services, and functions. In particular, Knative Services focuses on being easy to configure, deploy, and manage.

<h2 style="color:#0071c7;"> Workflow integrations</h2>

The open architecture allows Relay to integrate dozens of different services and platforms into workflows. A look at the <a href="https://github.com/relay-integrations">Relay integrations GitHub page</a> provides a list of these integrations and demonstrates their commitment to the open source community.

"I'm a strong believer in working with open source projects. We've made contributions to numerous projects, including Tekton, Knative, Ambassador, and gVisor, all of which we depend on to make our product functional," says Fontes.

<h2 style="color:#0071c7;"> Results: automated infrastructure management</h2>

While Relay's infrastructure runs on the Google Cloud Platform, it is a <a href="https://relay.sh/library/">library of workflows, integrations, steps, and triggers</a> that includes services across all major cloud service providers. Relay customers can integrate across Microsoft Azure, AWS, and Oracle Cloud Infrastructure among others. By combining these integrations with SaaS offerings, it truly is becoming the <a href=https://zapier.com/">Zapier</a> of infrastructure management.

“Our customers have diverse needs for managing their workloads that are often best implemented as web APIs. Our product provides a serverless microservice environment powered by Knative that allows them to build this complex tooling without the management and maintenance overhead of traditional deployment architectures. We pass the cost savings on to them, and everyone is happier," said Fontes.

Building and deploying Relay would not have been possible without the existing infrastructure offered by systems such as Knative and <a href="https://tekton.dev">Tekton</a>. Remarkably, Fontes' team never grew above eight engineers. Once they solidified their plan for Relay, they were able to bring it to production in just three months, says Fontes.

<h2 style="color:#0071c7;"><em>"Thanks to Knative, getting Relay out the door was easier than we thought it would be."</em> said Noah Fontes, Senior Principal Software Engineer.</h2>

Knative aims to make scalable, secure, stateless architectures available quickly by abstracting away the complex details of a Kubernetes installation and enabling developers to focus on what matters.

<h2 style="color:#0071c7;">Find out more</h2>

<ul>
<li><a href="../../../getting-started/">Getting started with Knative</a></li>
<li><a href="../../../serving/">Knative Serving</a></li>
<li><a href="../../../eventing/">Knative Eventing</a></li>
<li><a href="https://www.markheath.net/post/basic-introduction-webhooks">A Basic Introduction to Webhooks</a></li>
</ul>

    </td>
  </tr>
</table>
