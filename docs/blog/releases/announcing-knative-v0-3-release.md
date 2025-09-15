---
title: "v0.3 release"
linkTitle: "v0.3 release"
date: "2019-01-15"
description: "The Knative v0.3 release announcement"
type: "blog"
---

<article class="h-entry">

<section data-field="subtitle" class="p-summary">

Knative’s momentum continues! Once again, we are excited to announce a new release of Knative. After a series of architectural changes…

</section>

<section data-field="body" class="e-content">

<section name="b504" class="section section--body section--first section--last">

<div class="section-divider">

<hr class="section-divider">

</div>

<div class="section-content">

<div class="section-inner sectionLayout--insetColumn">

<h3 name="d708" id="d708" class="graf graf--h3 graf--leading graf--title">Announcing Knative v0.3 Release</h3>

<p name="feb7" id="feb7" class="graf graf--p graf-after--h3">Knative’s momentum continues! Once again, we are excited to announce a new release of Knative. After a series of architectural changes announced in the previous release, v0.3 implements many of the learnings from the growing number of Knative deployments, increases operational control, and improves stability.</p>

<p name="7e01" id="7e01" class="graf graf--p graf-after--p">As we move to a more predictable release schedule based on six week cadence, Knative releases will now be smaller and more frequent. We did this to enable a tighter feedback loop with our users and allow for smoother course corrections as we continue to learn from our growing number of users.</p>

<figure name="31b7" id="31b7" class="graf graf--figure graf--layoutOutsetLeft graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 200px; max-height: 200px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-image-id="knative" data-width="200" data-height="200" src="/blog/images/knative.png">

</div>

</figure>

<p name="de1e" id="de1e" class="graf graf--p graf-after--figure">Starting with the v0.3 release, Knative now requires Kubernetes 1.11, due to the use of `/status` sub-resource support, which went Beta in Kubernetes 1.11 and fixes a long-standing Kubernetes CRD bug.</p>

<p name="e124" id="e124" class="graf graf--p graf-after--p">The complete set of Knative v0.3 release notes outlining the new features as well as bug fixes and architectural changes are available in the <a href="https://github.com/knative/serving/releases/tag/v0.3.0" data-href="https://github.com/knative/serving/releases/tag/v0.3.0" class="markup--anchor markup--p-anchor" rel="noopener">Serving</a>, <a href="https://github.com/knative/build/releases/tag/v0.3.0" data-href="https://github.com/knative/build/releases/tag/v0.3.0" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Build</a>, and <a href="https://github.com/knative/eventing/releases/tag/v0.3.0" data-href="https://github.com/knative/eventing/releases/tag/v0.3.0" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Eventing</a> repositories. Here are a few highlights:</p>

<h3 name="c10b" id="c10b" class="graf graf--h3 graf-after--p">Serving API</h3>

<p name="0183" id="0183" class="graf graf--p graf-after--h3">With the v0.3 release, Knative now exposes a few additional parameters in its API. These include explicit Revision timeouts and the ability to specify the port for incoming traffic to the user container, which Knative previously exposed to the container using the “$PORT” environment variable.</p>

<p name="3fd8" id="3fd8" class="graf graf--p graf-after--p">An even bigger addition is support for the <a href="https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/" data-href="https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Kubernetes resources spec</a>, which allows you to specify reservations and limits on the user container. Besides allowing the service to specify how much CPU and memory (RAM) it needs or limit how much it can use; this also allows developers to request access to <a href="https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/" data-href="https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">hardware accelerators like GPU</a> if their cluster includes nodes configured with that capability.</p>

<p name="ca9e" id="ca9e" class="graf graf--p graf-after--p">In v0.3, Knative is also more proactive about rolling out operator changes. Changes to serving ConfigMaps are now immediately reconciled and rolled out.</p>

<h3 name="3ae8" id="3ae8" class="graf graf--h3 graf-after--p">Autoscaling</h3>

<p name="110d" id="110d" class="graf graf--p graf-after--h3">Building on the new single shared autoscaler introduced in the previous release, v0.3 introduces a more aggressive scale-to-zero strategy, which will by default scale Revisions down to zero pods after only 30 seconds of inactivity. The default Knative Pod Autoscaler (KPA) now supports revision-level concurrency targets.</p>

<p name="5db5" id="5db5" class="graf graf--p graf-after--p">As shown in our <a href="https://youtu.be/OPSIPr-Cybs" data-href="https://youtu.be/OPSIPr-Cybs" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Kubecon demo</a>, Knative now offers Horizontal Pod Autoscaler (HPA). This is useful for those who need to opt-out of KPA and use CPU instead of request rate as a scaling metric. (Note: HPA-class Revisions will not scale to zero).</p>

<p name="716d" id="716d" class="graf graf--p graf-after--p">Lastly, you can now also mutate `PodAutoscaler` specs in-place to adjust the scale bounds and other parameters.</p>

<h3 name="4108" id="4108" class="graf graf--h3 graf-after--p">Networking</h3>

<p name="7ce7" id="7ce7" class="graf graf--p graf-after--h3">A frequently-requested feature is the ability to deploy services which are not exposed externally and can only be accessed by other services in the cluster. In v0.3, Routes <a href="../../../../../docs/reference/serving-api/#RouteStatus">configured</a> to use the `svc.cluster.local` domain will only be exposed to the cluster-local Istio gateway. The cluster-local gateway will keep the deployed service inaccessible from outside the cluster. Developers can also use the `serving.knative.dev/visibility=cluster-local` label on their Route or Service to enable this behaviour.</p>

<p name="09bc" id="09bc" class="graf graf--p graf-after--p">Knative is also deprecating its dedicated Istio gateway. In v0.3 release, Knative will still expose public routes to both the deprecated gateway and the default Istio gateway. Starting with next release however, Knative will remove the deprecated gateway to further reduce overhead and avoid the additional cost of public IP. (Note, you may have to update the gateway IP in your DNS mappings).</p>

<h3 name="d066" id="d066" class="graf graf--h3 graf-after--p">Eventing</h3>

<p name="7ef7" id="7ef7" class="graf graf--p graf-after--h3">With the inclusion of Eventing in the previous release, there has been a significant focus on extending the number of and documenting available external event sources which can be installed in Knative as Kubernetes Custom Resource Definitions (CRDs). The complete list of currently supported event sources can be found <a href="../../../../../docs/developer/eventing/sources#sources">here</a>.</p>

<h3 name="87ba" id="87ba" class="graf graf--h3 graf-after--p">Build</h3>

<p name="9e6a" id="9e6a" class="graf graf--p graf-after--h3">The Knative Build component can now support both single `source` and multiple input `sources`. If multiple sources are requested, each will be fetched in declared order and placed into a directory under `/workspace` named after the source’s name field. The Build controller is also now subject to the PodSecurityPolicy which enables cluster operators to specify further limitations.</p>

<h3 name="6e57" id="6e57" class="graf graf--h3 graf-after--p">Monitoring</h3>

<p name="8ad2" id="8ad2" class="graf graf--p graf-after--h3">Metric labels should now be consistent across all of the Knative components. Also, in addition to the default Prometheus metric target, Knative control plane metrics (from Reconciler, Autoscaler, and Activator) can now be exported directly to Stackdriver.</p>

<h3 name="7ec8" id="7ec8" class="graf graf--h3 graf-after--p">Learn more</h3>

<ul class="postList">

<li name="c00d" id="c00d" class="graf graf--li graf-after--h3">

<a href="../../../../../docs/" data-href="../../../../../docs/" class="markup--anchor markup--li-anchor" rel="noopener">Welcome to Knative</a>

</li>

<li name="d88a" id="d88a" class="graf graf--li graf-after--li">

<a href="../../../../../docs/#documentation" data-href="../../../../../docs/#documentation" class="markup--anchor markup--li-anchor" rel="noopener">Getting started documentation</a>

</li>

<li name="a9ca" id="a9ca" class="graf graf--li graf-after--li">

<a href="../../../../../docs/#samples-and-demos" data-href="../../../../../docs/#samples-and-demos" class="markup--anchor markup--li-anchor" rel="noopener">Samples and demos</a>

</li>

<li name="fe75" id="fe75" class="graf graf--li graf-after--li">

<a href="../../../../../contributing/#meetings-and-work-groups" data-href="../../../../../contributing/#meetings-and-work-groups" class="markup--anchor markup--li-anchor" rel="noopener">Knative meetings and work groups</a>

</li>

<li name="cf03" id="cf03" class="graf graf--li graf-after--li">

<a href="../../../../../contributing/#questions-and-issues" data-href="../../../../../contributing/README.md#questions-and-issues" class="markup--anchor markup--li-anchor" rel="noopener">Questions and issues</a>

</li>

<li name="19ce" id="19ce" class="graf graf--li graf-after--li">Knative on Twitter (<a href="https://twitter.com/KnativeProject" data-href="https://twitter.com/KnativeProject" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">@KnativeProject</a>)</li>

<li name="5fcb" id="5fcb" class="graf graf--li graf-after--li">Knative on <a href="https://stackoverflow.com/questions/tagged/knative" data-href="https://stackoverflow.com/questions/tagged/knative" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">StackOverflow</a>

</li>

<li name="3813" id="3813" class="graf graf--li graf-after--li graf--trailing">Knative <a href="https://slack.knative.dev/" data-href="https://slack.knative.dev/" class="markup--anchor markup--li-anchor" rel="noopener">Slack</a>

</li>

</ul>

</div>

</div>

</section>

</section>

<footer>

<p>By <a href="https://medium.com/@mchmarny_google" class="p-author h-card">Mark Chmarny</a> on <a href="https://medium.com/p/18d738c225c3">

<time class="dt-published" datetime="2019-01-15T17:58:06.784Z">January 15, 2019</time>

</a>.</p>

<p>

<a href="https://medium.com/@mchmarny_google/announcing-knative-v0-3-release-18d738c225c3" class="p-canonical">Canonical link</a>

</p>

<p>Exported from <a href="https://medium.com">Medium</a> on January 23, 2019.</p>

</footer>

</article>
