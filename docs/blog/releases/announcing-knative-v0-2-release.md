---
title: "v0.2 release"
linkTitle: "v0.2 release"
date: 2018-11-14
description: "The Knative v0.2 release announcement"
type: "blog"
---

<article class="h-entry">


<section data-field="subtitle" class="p-summary">

Improved pluggability, autoscaling, stability, and performance

</section>

<section data-field="body" class="e-content">

<section name="2748" class="section section--body section--first section--last">

<div class="section-divider">

<hr class="section-divider">

</div>

<div class="section-content">

<div class="section-inner sectionLayout--insetColumn">

<h3 name="d4ac" id="d4ac" class="graf graf--h3 graf--leading graf--title">Announcing Knative v0.2 Release</h3>

<p name="93a1" id="93a1" class="graf graf--p graf-after--h3">Improved pluggability, autoscaling, stability, and performance</p>

<p name="42e2" id="42e2" class="graf graf--p graf-after--p">We are excited to announce a new release of Knative, the set of middleware components for building modern applications on Kubernetes. The 0.2 release of Knative is the first significant update since the project’s launch in July. It represents months of hard work by the entire Knative community to address our learnings from the growing number of Knative deployments.</p>

<figure name="52f3" id="52f3" class="graf graf--figure graf--layoutOutsetLeft graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 441px; max-height: 356px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-image-id="knative.png" data-width="441" data-height="356" data-is-featured="true" src="/blog/images/knative.png">

</div>

</figure>

<p name="42db" id="42db" class="graf graf--p graf-after--figure">The most exciting aspect of the 0.2 release is the inclusion of eventing. The Eventing component complements the other two foundational blocks already defined by Knative: Serving and Build. We look forward to the new types of events and innovative solutions the community will develop using this new capability.</p>

<p name="6aed" id="6aed" class="graf graf--p graf-after--p">Serving made significant improvements “under the hood,” encapsulating key areas of Knative into subsystems with new internal APIs to enable support for pluggable networking, autoscaling, and caching.</p>

<p name="bb3e" id="bb3e" class="graf graf--p graf-after--p">The complete release notes are available in Knative <a href="https://github.com/knative/serving/releases/tag/v0.2.1" data-href="https://github.com/knative/serving/releases/tag/v0.2.1" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Serving</a>, <a href="https://github.com/knative/build/releases/tag/v0.2.0" data-href="https://github.com/knative/build/releases/tag/v0.2.0" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Build</a>, and <a href="https://github.com/knative/eventing/releases/tag/v0.2.0" data-href="https://github.com/knative/eventing/releases/tag/v0.2.0" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Eventing</a> repositories. Here are a few highlights:</p>

<p name="02e7" id="02e7" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">New Eventing Resource Model <br>

</strong>The eventing repo went through a significant rework of the resource model, resulting in migration of sources into Custom Resource Definitions (CRDs). Now, eventing includes a sophisticated use of standard Kubernetes concepts, resulting in better validation, cleaner interfaces, and RBAC support. The new architecture uses a simpler object model that is centered around channels and subscriptions.</p>

<p name="92d4" id="92d4" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Looser Coupling<br>

</strong>One of the pieces of positive feedback we received on v0.1 was the “tasteful” choices defining Knative building blocks. In v0.2, Knative leans into this even further to enable operators to install the Build, Serving, and Eventing components independent of one another. The contract that enables these loose couplings between Knative components will also enable third party integrations over time, such as using a non-Knative Build with Serving, or delivering events to non-Serving deployments. We are excited to see what direction the community takes this.</p>

<p name="98f1" id="98f1" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Pluggable Subsystems</strong>

<br>We also got a lot of feedback about wanting to customize Knative. The goal was always to support some measure of pluggability, so customization was significantly improved in v0.2. We introduced 3 new internal APIs in v0.2 to separate our core resource model from the subsystems that implement them: Networking, Autoscaling, and Caching. Networking enables developers to replace our Istio dependency with alternative ingress implementations. Autoscaling enables developers to replace our “cheap and cheerful” autoscaler with one of their own designs. Caching enables developers to employ image caching strategies to preload container images across their cluster (no implementation bundled, so this is a pure extension-point).</p>

<p name="d31d" id="d31d" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Improved Cold-Starts</strong>

<br>Two of the dominant factors in cold-start performance are side-car injection and image pull latency. With their 1.0.2 release, Istio has made progress on reducing the Envoy programming time. In addition, we’ve made it possible to install Knative with side-car injection disabled. To enable folks to combat image pull latency, we have exposed a new extension point called an “Image” resource (part of knative/caching), which contains all the information needed for a controller to pre-load user images across a cluster. Caching is another feature we are excited to see the community build upon.</p>

<p name="f099" id="f099" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Autoscaling</strong>

<br>We have replaced the previous per-Revision autoscalers with a single shared autoscaler. The new autoscaler is based on the same logic as the previous autoscaler, but has evolved to be purely metrics driven (including 0-&gt;1-&gt;0), eliminating the unnecessary Revision servingState field. We have replaced ConcurrencyModel (Single or Multi) with an integer ContainerConcurrency field. This allows limiting concurrency to values other than 1 for certain use cases (for example, limited thread pools).</p>

<p name="44ae" id="44ae" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Build</strong>

<br>Knative Build added many incremental improvements, including the new ClusterBuildTemplate resource. Operators are now able to install a set of BuildTemplates one time instead of once per-Namespace. Build template parameters can now also apply to build step image names. New features of the Build spec allow users to specify a build-wide timeout, node selectors, and affinity. Last but not least, build status has been extended to report per-step build progress and build pending times.</p>

<h3 name="7b11" id="7b11" class="graf graf--h3 graf-after--p">Knative at KubeCon</h3>

<p name="1629" id="1629" class="graf graf--p graf-after--h3">Come and talk to us! There are a number of Knative sessions at the upcoming KubeCon conferences, both in Shanghai and Seattle.</p>

<p name="2e0b" id="2e0b" class="graf graf--p graf-after--p">

<strong class="markup--strong markup--p-strong">Shanghai</strong>

</p>

<ul class="postList">

<li name="7bd0" id="7bd0" class="graf graf--li graf-after--p">

<a href="https://kccncchina2018english.sched.com/event/FuKU/botless-a-serverless-chatbot-framework-scott-nichols-google" data-href="https://kccncchina2018english.sched.com/event/FuKU/botless-a-serverless-chatbot-framework-scott-nichols-google" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Botless: A Serverless Chatbot Framework</a>

</li>

</ul>

<p name="7514" id="7514" class="graf graf--p graf-after--li">

<strong class="markup--strong markup--p-strong">Seattle</strong>

</p>

<ul class="postList">

<li name="4329" id="4329" class="graf graf--li graf-after--p">

<a href="https://kccna18.sched.com/event/Grbz/intro-knative-productivity-bof-srinivas-v-hegde-adriano-cunha-google" data-href="https://kccna18.sched.com/event/Grbz/intro-knative-productivity-bof-srinivas-v-hegde-adriano-cunha-google" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Intro: Knative Productivity BoF</a>

</li>

<li name="1b05" id="1b05" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/Gra9/knative-scaling-from-0-to-infinity-joseph-burnett-mark-chmarny-google" data-href="https://kccna18.sched.com/event/Gra9/knative-scaling-from-0-to-infinity-joseph-burnett-mark-chmarny-google" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Knative: Scaling From 0 to Infinity</a>

</li>

<li name="4549" id="4549" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GrVt/machine-learning-model-serving-and-pipeline-using-knative-animesh-singh-ibm" data-href="https://kccna18.sched.com/event/GrVt/machine-learning-model-serving-and-pipeline-using-knative-animesh-singh-ibm" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Machine Learning Model Serving and Pipeline Using Knative</a>

</li>

<li name="799d" id="799d" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GraR/tutorial-getting-your-hands-dirty-with-knative-bas-tichelaar-ade-mochtar-instruqt" data-href="https://kccna18.sched.com/event/GraR/tutorial-getting-your-hands-dirty-with-knative-bas-tichelaar-ade-mochtar-instruqt" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Tutorial: Getting Your Hands Dirty with Knative</a>

</li>

<li name="34f6" id="34f6" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GrSt/building-container-images-on-your-kubernetes-cluster-with-knative-build-gareth-rushgrove-docker" data-href="https://kccna18.sched.com/event/GrSt/building-container-images-on-your-kubernetes-cluster-with-knative-build-gareth-rushgrove-docker" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Building Container Images on Your Kubernetes Cluster with Knative Build</a>

</li>

<li name="83cf" id="83cf" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GraI/how-to-build-deep-learning-inference-through-knative-serverless-framework-huamin-chen-yehuda-sadeh-weinraub-red-hat" data-href="https://kccna18.sched.com/event/GraI/how-to-build-deep-learning-inference-through-knative-serverless-framework-huamin-chen-yehuda-sadeh-weinraub-red-hat" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">How to Build Deep Learning Inference Through Knative Serverless Framework</a>

</li>

<li name="25e8" id="25e8" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GraC/t-mobile-store-locator-serverless-journey-with-knative-and-kubernetes-ram-gopinathan-t-mobile" data-href="https://kccna18.sched.com/event/GraC/t-mobile-store-locator-serverless-journey-with-knative-and-kubernetes-ram-gopinathan-t-mobile" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">T-Mobile Store Locator Serverless Journey with Knative and Kubernetes</a>

</li>

<li name="e7e0" id="e7e0" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/GraF/birds-of-a-feather-knative-jessie-zhu-google" data-href="https://kccna18.sched.com/event/GraF/birds-of-a-feather-knative-jessie-zhu-google" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Birds of a Feather: Knative</a>

</li>

<li name="e022" id="e022" class="graf graf--li graf-after--li">

<a href="https://kccna18.sched.com/event/Grdv/deep-dive-knative-productivity-bof-jessie-zhu-adriano-cunha-google" data-href="https://kccna18.sched.com/event/Grdv/deep-dive-knative-productivity-bof-jessie-zhu-adriano-cunha-google" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Deep Dive: Knative Productivity BoF</a>

</li>

<li name="a3b3" id="a3b3" class="graf graf--li graf-after--li graf--trailing">

<a href="https://kccna18.sched.com/event/IRr7/deploying-serverless-apps-to-kubernetes-with-knative-additional-registration-fee-required" data-href="https://kccna18.sched.com/event/IRr7/deploying-serverless-apps-to-kubernetes-with-knative-additional-registration-fee-required" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Deploying serverless apps to Kubernetes with Knative</a> (Additional registration and fees required)</li>

</ul>

</div>

</div>

</section>

</section>

<footer>

<p>By <a href="https://medium.com/@mchmarny_google" class="p-author h-card">Mark Chmarny</a> on <a href="https://medium.com/p/963f276af58e">

<time class="dt-published" datetime="2018-11-14T02:26:34.071Z">November 14, 2018</time>

</a>.</p>

<p>

<a href="https://medium.com/@mchmarny_google/https-medium-com-knative-v0-2-963f276af58e" class="p-canonical">Canonical link</a>

</p>

<p>Exported from <a href="https://medium.com">Medium</a> on January 8, 2019.</p>

</footer>

</article>
