---
title: "v0.4 release"
linkTitle: "v0.4 release"
date: 2019-02-20
description: "The Knative v0.4 release announcement"
type: "blog"
---

<article class="h-entry">

<section data-field="subtitle" class="p-summary">

Knative v0.4 release responds to ongoing and direct feedback from the growing number of deployments

</section>

<section data-field="body" class="e-content">

<section name="b504" class="section section--body section--first section--last">

<div class="section-divider">

<hr class="section-divider">

</div>

<div class="section-content">

<div class="section-inner sectionLayout--insetColumn">

<h3 name="d708" id="d708" class="graf graf--h3 graf--leading graf--title">Announcing Knative v0.4 Release</h3>

<p name="feb7" id="feb7" class="graf graf--p graf-after--h3">Once again, we are excited to announce updates to <a href="https://www.knative.dev/" data-href="https://www.knative.dev/" class="markup--anchor markup--p-anchor" rel="nofollow noopener">Knative</a>. The v0.4 release continues to respond to ongoing direct feedback from the growing number of deployments. In each release, Knative implements these learnings based on new use-cases that are now being addressed with our platform.</p>

<figure name="545f" id="545f" class="graf graf--figure graf--layoutOutsetLeft graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 200px; max-height: 200px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<div class="progressiveMedia js-progressiveMedia graf-image" data-image-id="knative" data-width="200" data-height="200">
<img src="/blog/images/knative.png">

</div>

</div>

</figure>

<p name="0fec" id="0fec" class="graf graf--p graf-after--figure">The areas where we received the most feedback were: configuration and secret management.</p>

<p name="f70a" id="f70a" class="graf graf--p graf-after--p">As Knative maintains its predictable release cadence, the ability to preserve the settings from your previous installation (e.g. domain) became even more important. So, in the v0.4 release, Knative now preserves previously set ConfigMap values during the update process. Starting with subsequent releases, users should be able to simply apply the latest knative/serving release and continue using their previous settings.</p>

<p name="28b2" id="28b2" class="graf graf--p graf-after--p">With regards to secret management, Knative users have frequently asked for more flexibility with Secrets (for confidential data) and ConfigMaps (for non-confidential data). To address that need, Knative has now <a href="https://www.knative.dev/docs/serving/samples/secrets-go" data-href="https://www.knative.dev/docs/serving/samples/secrets-go" class="markup--anchor markup--p-anchor" rel="nofollow noopener">added support</a> for mounting Secrets and ConfigMaps as volumes.</p>

<figure name="94b1" id="94b1" class="graf graf--figure graf--layoutOutsetLeft graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 200px; max-height: 200px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<div class="progressiveMedia js-progressiveMedia graf-image" data-image-id="grpc" data-width="200" data-height="200">

<img src="/blog/images/grpc.png">

</figure>

<p name="c7c6" id="c7c6" class="graf graf--p graf-after--figure">Another area where we had a lot of feedback almost since the initial release of Knative was the need for additional network protocol support besides basic HTTP. I’m happy to say that with the v0.4 release Knative now also <a href="https://www.knative.dev/docs/serving/samples/grpc-ping-go" data-href="https://www.knative.dev/docs/serving/samples/grpc-ping-go" class="markup--anchor markup--p-anchor" rel="nofollow noopener">supports</a> both HTTP2 and gRPC for ports named h2c. There are still some challenges with streaming RPC during cold-starts so we look forward to your feedback.</p>

<p name="b291" id="b291" class="graf graf--p graf-after--p">Additionally, Knative also now <a href="https://github.com/mchmarny/knative-ws-example" data-href="https://github.com/mchmarny/knative-ws-example" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">supports</a> the ability to upgrade an inbound HTTP connection for WebSockets. This change involved plumbing through various layers of serving infrastructure, including activator and Istio VirtualService, so we are happy to finally land this often requested feature in Knative.</p>

<p name="6238" id="6238" class="graf graf--p graf-after--p">As with previous releases, Knative autoscaling continues to be an area of focus. The v0.4 release is no different, and once again, it improves on cold-start times by immediately scaling up when the autoscaler gets stats from activator. This reduces the latency when Knative must activate a previously scaled-to-zero workload. Additionally, the Serving activator also now throttles traffic it sends to scaled to zero pods to avoid overloading a single pod during initial large bursts of traffic.</p>

<figure name="2e47" id="2e47" class="graf graf--figure graf--layoutOutsetLeft graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 200px; max-height: 200px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<div class="progressiveMedia js-progressiveMedia graf-image" data-image-id="istio" data-width="200" data-height="200">

<img src="/blog/images/istio.png" crossorigin="anonymous" class="progressiveMedia-thumbnail js-progressiveMedia-thumbnail">

</figure>

<p name="353e" id="353e" class="graf graf--p graf-after--figure">As we indicated in the previous release, starting with the v0.4 release, Knative removes the customized Istio IngressGateway to enhance support for multiple versions of Istio and to reduce the number of needed load balancers. Users upgrading from the v0.3 release will need to reconfigure their DNS to point to the IP address exposed by istio-ingressgateway before upgrading, and remove the knative-ingressgateway Service and Deployment.</p>

<p name="c01a" id="c01a" class="graf graf--p graf-after--p">Finally, the v0.4 release of Knative serving adds an option to change the default ClusterIngress controller in the config-network ConfigMap from Istio if another controller is necessary.</p>

<p name="c64f" id="c64f" class="graf graf--p graf-after--p">In Eventing, the in-memory channel is now buffering events in memory rather than acting as a proxy. This change improves efficiency and throughput of event sources by reducing client blocking.</p>

<p name="38b9" id="38b9" class="graf graf--p graf-after--p">The complete set of Knative v0.4 release notes outlining the new features as well as bug fixes are available in the <a href="https://github.com/knative/serving/releases/tag/v0.4.0" data-href="https://github.com/knative/serving/releases/tag/v0.4.0" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">Serving</a>, <a href="https://github.com/knative/build/releases/tag/v0.4.0" data-href="https://github.com/knative/build/releases/tag/v0.4.0" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">Build</a>, and <a href="https://github.com/knative/eventing/releases/tag/v0.4.0" data-href="https://github.com/knative/eventing/releases/tag/v0.4.0" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">Eventing</a> repositories.</p>

<h3 name="363c" id="363c" class="graf graf--h3 graf-after--p">Learn more</h3>

<ul class="postList">

<li name="c00d" id="c00d" class="graf graf--li graf-after--h3">

<a href="https://www.knative.dev/docs#welcome-to-knative" data-href="https://www.knative.dev/docs#welcome-to-knative" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener">Welcome to Knative</a>

</li>

<li name="d88a" id="d88a" class="graf graf--li graf-after--li">

<a href="https://www.knative.dev/docs#documentation" data-href="https://www.knative.dev/docs#documentation" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener">Getting started documentation</a>

</li>

<li name="a9ca" id="a9ca" class="graf graf--li graf-after--li">

<a href="https://www.knative.dev/docs#samples-and-demos" data-href="https://www.knative.dev/docs#samples-and-demos" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener">Samples and demos</a>

</li>

<li name="fe75" id="fe75" class="graf graf--li graf-after--li">

<a href="https://www.knative.dev/contributing/#meetings-and-work-groups" data-href="https://www.knative.dev/contributing/#meetings-and-work-groups" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener">Knative meetings and work groups</a>

</li>

<li name="cf03" id="cf03" class="graf graf--li graf-after--li">

<a href="https://www.knative.dev/contributing/#questions-and-issues" data-href="https://www.knative.dev/contributing/#questions-and-issues" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener">Questions and issues</a>

</li>

<li name="19ce" id="19ce" class="graf graf--li graf-after--li">Knative on Twitter (<a href="https://twitter.com/KnativeProject" data-href="https://twitter.com/KnativeProject" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener" target="_blank">@KnativeProject</a>)</li>

<li name="5fcb" id="5fcb" class="graf graf--li graf-after--li">Knative on <a href="https://stackoverflow.com/questions/tagged/knative" data-href="https://stackoverflow.com/questions/tagged/knative" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener" target="_blank">StackOverflow</a>

</li>

<li name="3813" id="3813" class="graf graf--li graf-after--li graf--trailing">Knative <a href="https://slack.knative.dev/" data-href="https://slack.knative.dev/" class="markup--anchor markup--li-anchor" rel="nofollow noopener nofollow noopener" target="_blank">Slack</a>

</li>

</ul>

</div>

</div>

</section>

</section>

</article>
