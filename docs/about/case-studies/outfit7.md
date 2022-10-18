---
hide:
  - toc
---
<h1 style="color:#0071c7;font-size: 3em;">Outfit7 Case Study</h1>
<table style="border: 0;">
<tr style="background-color: var(--md-default-bg-color);">
<td style="border: 0;">
<div style="min-width: 20mm;">
      <img src="../../../images/case-studies/outfit7.png" alt="" draggable="false" />
</div>
<div>
<em style="color:#0071c7;font-size: 1em;">"The community support is really great. The hands-on experience with Knative was so impressive. On the Slack channel, we got actual engineers to answer our questions"</em>
</div>
<div>
<p style="color:#0071c7;font-size: 1em;">-- Tilen Kavčič, Software Engineer for Outfit7</p>
</div>

</td>

<td style="border: 0;">

<h2 style="font-weight: bold;">Game maker Outfit7 automates high performance ad bidding with Knative Serving</h2>


Since its founding in 2009, the mobile gaming company Outfit7 has seen astronomical growth—garnering over 17 billion downloads and over 85 billion video views last year.

Outfit7 was in the Top 5 game publishers list on iOS and Google Play worldwide by the number of game downloads for 6 consecutive years (2015 - 2020). With their latest launch, My Talking Angela 2, they were number 1 by global games downloads in July, August, and September (more than 120 million downloads).

The success of the well-known game developer behind massive hits like the Talking Tom & Friends franchise and stand-alone titles like Mythic Legends created large-scale challenges.

With up to 470 million monthly active users, 20 thousand server requests per second, and terabytes of data generated daily, they needed a stable, high performance solution. They turned to a Knative and Kubernetes solution to optimize real-time bidding ad sales in a way that can automatically scale up and down as needed.  They were able to develop a system so easy to maintain that it freed up two software engineers who are now able to work on more important tasks, like optimizing backend costs and adding new game features.

<h2 style="color:#0071c7;">High performance in-app bidding</h2>

Ad sales are an important revenue stream of Outfit7. The team needed to walk a careful balance: sell the space for the highest bid, use technical resources efficiently, and make sure ads are served to players quickly. To achieve this they decided to adopt an in-app bidding approach.

The Outfit7 user base generates around 8,000 ad-related requests per second. With so many users spread worldwide, the amount of these requests can drop or surge depending on all sorts of factors. Not just predictable things like the time of day, but current events can suddenly create traffic. The pandemic saw their usage soar, for instance.

To manage the process in-house, the team needed to be able to test and deploy very efficiently. "There were two specific use cases we wanted to cover," explained Luka Draksler, backend engineer in the ad technology department at Outfit7. "One was to have the ability to do zero downtime canary deployments using an automatic gradual rollout process. This works in a way that the new version of the software is deployed using a continuous deployment pipeline with a small amount of traffic first. If everything checks out, all production traffic is migrated to the new version. In the worst-case scenario (if requests start failing) traffic can be quickly migrated to the old version. The second use-case was the ability to have developers deploy versions to specific groups of users for instances of A/B testing and other use cases."

The team decided to adopt Knative Serving as the backbone of their solution. Knative allowed Outfit7 to streamline deployments and cut down on development time. After being surprised at how easily they generated an internal proof of concept, the team saw that it could craft custom solutions tuned for their internal workflows—without consuming valuable developer time. In addition, they could quickly configure A/B testing and deploy multiple versions of code simultaneously.

<h2 style="color:#0071c7;">Serverless solution</h2>

Knative Serving gave Outfit7 access to a robust set of tools and features that allows their team to automate and monitor the deployment of applications to handle ad requests. When more requests are coming in, their system automatically spins up more containers that house the workers and tools. When these requests drop, unneeded containers shut down. Outfit7 only pays for the resources they require for the current load.

Knative works as a layer installed on top of Kubernetes. It brings the power of serverless workloads to the scalable capabilities of Kubernetes. Teams quickly spin up container-based applications without needing to consider the details of Kubernetes.

Knative also simplifies project deployments to Kubernetes. Mitja Bezenšek, the Lead Developer on Outfit7's backend team, estimated that the traditional development that Knative replaced would have required three full-time engineers to maintain. Their new platform operates with minimal work and allows the developers to deploy updates at will.

<h2 style="color:#0071c7;">The open source community</h2>

Outfit7's team was blown away by the supportive and helpful community around Knative. After discovering a problem with network scaling, the team was surprised by how easy it was to find answers and solutions.

<h2 style="color:#0071c7;"><em>"The community support is really great. The hands-on experience with Knative was so impressive. On the Slack channel, we got actual engineers to answer our questions"</em> -- Tilen Kavčič, Software Engineer for Outfit7</h2>

<h2 style="color:#0071c7;">Sharing their story</h2>

The great experience with Knative encouraged their team to share their experience with fellow companies and engineers at a local meetup. The presentation which included several live demos was a success, helping spawn another meet-up focused on the technology. "Tilen showed them the demo and what it's all about," said Bezenšek. "I hope we got them engaged going forward."

<h2 style="color:#0071c7;">Looking forward</h2>

Outfit7 shows no signs of slowing down. “As we want to support our vision in expanding our games portfolio, we are always looking for new strategic partners who can accompany us on this path,” added Helder Lopes, Head of R&D in Cyprus headquarters. The company plans to incorporate and adopt Knative into other back-end systems – taking advantage of the easier workflows that Knative offers.

<h2 style="color:#0071c7;">Find out more</h2>

<ul>
<li><a href="../../../getting-started/">Getting started with Knative</a></li>
<li><a href="../../../serving/">Knative Serving</a></li>
<li><a href="../../../eventing/">Knative Eventing</a></li>
</ul>

    </td>
  </tr>
</table>
