# Knative v0.3 Autoscaling — A Love Story

**Author: [Joseph Burnett](https://github.com/josephburnett), Software Engineer @ Google**

**Date: 2019-03-27**

<article class="h-entry">

<section data-field="subtitle" class="p-summary">

Scaling in the Knative v0.3 release includes new options for customizing the autoscaling subsystem. From a batteries-included…

</section>

<section data-field="body" class="e-content">

<section name="f67c" class="section section--body section--first section--last">

<div class="section-divider">

<hr class="section-divider">

</div>

<div class="section-content">

<div class="section-inner sectionLayout--insetColumn">

<h3 name="1b46" id="1b46" class="graf graf--h3 graf--leading graf--title">Knative v0.3 Autoscaling — A Love Story</h3>

<p name="9627" id="9627" class="graf graf--p graf-after--h3">Scaling in the Knative v0.3 release includes new options for customizing the autoscaling subsystem. From a batteries-included, scale-to-zero default, to an ability to replace the autoscaling system entirely, and everything in between. PodAutoscaler, the new custom resource in Knative, provides an extension and control point with which to configure your application.</p>

<p name="045a" id="045a" class="graf graf--p graf-after--p">To illustrate these options, let’s walk through the evolution of a Web application from inception to complex autoscaling. We promise, “Knative Autoscaling will grow old with you.”</p>

<h3 name="2645" id="2645" class="graf graf--h3 graf-after--p">I just wanna keep it simple</h3>

<p name="e70a" id="e70a" class="graf graf--p graf-after--h3">One morning, you sit bolt upright in bed struck by the realization that what people really want… is love. You write a quick Web application to apply a heart-shaped watermark to any given image in just the right place. Since you’re a savvy, modern application developer, you drop it in a container and spin it up on a Knative Service on GKE with `gcloud run deploy — image gcr.io/joe-does-knative/love`.</p>

<p name="55ba" id="55ba" class="graf graf--p graf-after--p">This is what your Knative Service looks like:</p>

<figure name="986d" id="986d" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 334px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="1574" data-height="752" src="/blog/articles/images/1_F-mOzMbo-Yy2XWTSgJkfQA.png">

</div>

</figure>

</figure>

<p name="a160" id="a160" class="graf graf--p graf-after--figure">You show it to your BFF and they post it on Hacker News. Voila, you’re on the front page of the hacker’s Internet! HN tries to give you the hug-of-death, but your application and cluster scales up to handle 1000 op/s of traffic seamlessly. After a while, the excitement dies down and your service is getting 1 or 2 requests per hour. Luckily, Knative scales to zero Pods when not in use, so you don’t spend money running an idle process. And you never changed anything after the initial deployment! That was simple.</p>

<figure name="75df" id="75df" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 520px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-image-id="gopher" data-width="800" data-height="594" src="/blog/articles/images/gopher.png">

</div>

</figure>

<figcaption>

<small>Original image: <a href="https://cheezburger.com/7892518656/gopher-love">https://cheezburger.com/7892518656/gopher-love</a>

</small>

</figcaption>

<h3 name="cc2e" id="cc2e" class="graf graf--h3 graf-after--figure">Please don’t go away</h3>

<p name="dc4d" id="dc4d" class="graf graf--p graf-after--h3">Several weeks later, lightning strikes again and you realize… “I could make money doing this”. Clearly people enjoyed the heart-shaped watermarks. Maybe you could let people use your service to watermark images on their entire website! Adding a quick in-memory cache in front of your Ruby script (yeah, it’s Ruby) you redeploy and then start advertising your product as a general image-processing service. Things are going well, but you quickly realize that your traffic is unpredictable — it bursts a lot. And when the service scales to 0 Pods and later the traffic resumes, you spend the first few minutes building up the cache again, which makes request latency a little too high. So you decide to add an annotation to your Knative Service’s Revision template to maintain at least 2 Pods at all times.</p>

<p name="1828" id="1828" class="graf graf--p graf-after--p">This is what your Knative Service looks like now:</p>

<figure name="cb2d" id="cb2d" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 425px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="1578" data-height="958" src="../../../../articles/images/1_BkMXQfMrRERP_n04_C7geQ.png">

</div>

</figure>

<p name="c288" id="c288" class="graf graf--p graf-after--figure">Things aren’t scaling to zero. But that’s fine because you’re making a little money from the venture.</p>

<h3 name="6915" id="6915" class="graf graf--h3 graf-after--p">Things are heating up</h3>

<p name="8920" id="8920" class="graf graf--p graf-after--h3">Woah! Traffic is starting to ramp up. You’re averaging about 500 op/s and running between 10 and 50 Pods depending on the time of day. You’ve noticed that this job is mostly CPU-bound and you’re not utilizing all your resources as efficiently as you could. So you make some adjustments to the default autoscaling target:</p>

<figure name="51a1" id="51a1" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 175px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="1520" data-height="380" src="/blog/articles/images/1_O6ZSdCeotT7J4zSbDNIsYw.png">

</div>

</figure>

<p name="68f8" id="68f8" class="graf graf--p graf-after--figure">But eventually you conclude that you just need to scale on CPU to keep your machines hot. So you choose a different Knative autoscaling class entirely. The class annotation will tell Knative to use a different PodAutoscaler controller implementation, kinda like Kubernetes Ingress.</p>

<p name="cdaa" id="cdaa" class="graf graf--p graf-after--p">Here is your Knative Service now:</p>

<figure name="1d64" id="1d64" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 378px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="2010" data-height="1084" src="/blog/articles/images/1_fSxikLtB7TNsV-6Y3u5g2w.png">

</div>

</figure>

<p name="3827" id="3827" class="graf graf--p graf-after--figure">Running at 60% CPU consistently you’re actually starting to make more money than you’re spending! So you quit your day job to pursue heart-shaped watermarking full time.</p>

<h3 name="cfd7" id="cfd7" class="graf graf--h3 graf-after--p">Let’s get serious</h3>

<p name="5397" id="5397" class="graf graf--p graf-after--h3">Things are getting complicated. Seeking professional help, you hire Dr. Mark to help you run your service operations. One of the first things he implements is rollout mode for your service. No more leaping before you look!</p>

<figure name="3d05" id="3d05" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 462px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="2000" data-height="1320" src="/blog/articles/images/1_znzl9nGKIif51YRwmBw_BA.png">

</div>

</figure>

<p name="d2e5" id="d2e5" class="graf graf--p graf-after--figure">Things are smooth sailing with Dr. Mark at the helm! As the weeks roll on, New Year’s Eve approaches and you start seeing non-linear growth in your metrics. A quick consultation with Dr. Mark confirms your worst fears. People go crazy sending each other pictures with hearts on New Year’s Eve. And they do it <strong class="markup--strong markup--p-strong">all at the same time</strong> like they are coordinating a DDOS attack of love. You’re going to need a plan.</p>

<p name="eb80" id="eb80" class="graf graf--p graf-after--p">Luckily, Dr. Mark has been doing his reading in the Knative Serving release notes and begins experimenting with editing the PodAutoscaler on pre-existing Knative Revisions. The PodAutoscaler is where Knative keeps its autoscaling state and configuration for a Knative Revision. And unlike the Knative Revision, it’s mutable (on purpose). You make a plan to ramp up capacity slightly ahead of traffic as it builds to each NYE event across the globe (yeah, it happens 24 times!)</p>

<figure name="2941" id="2941" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 303px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="2360" data-height="1022" src="/blog/articles/images/1_OwJCCIaSFFSE1Rv6ZPuTBQ.png"> </div>

</figure>

<p name="0f7a" id="0f7a" class="graf graf--p graf-after--figure">Over the course of the evening, New Year’s marches from timezone to timezone. You see a few minutes of errors on the first NYE event because the CPU target of 60% is too high. But after you adjust it down to 40% for the next event, it’s smooth sailing for the rest of the evening. Hooray! 🎉</p>

<h3 name="45d7" id="45d7" class="graf graf--h3 graf-after--p">You’re so special</h3>

<p name="f604" id="f604" class="graf graf--p graf-after--h3">It’s been a full year and things have been crazy! You’ve done some deep integrations with several major image hosting websites and they are driving like 80% of your traffic and revenue now. With a little time on your hands, you start analyzing your autoscaling statistics. You realize that traffic observed by your upstream referrers almost <strong class="markup--strong markup--p-strong">perfectly</strong> predicts your traffic patterns. And they can give you those metrics through your API integration!</p>

<p name="b6dd" id="b6dd" class="graf graf--p graf-after--p">But you have implemented your CI/CD pipeline to work with Knative. And all your operational experience is in running Knative workloads. It would be a shame to throw all that out just to implement your own autoscaling algorithm. But then you remember something Dr. Mark said way back when he started looking in to Knative v0.3. With the PodAutoscaler custom resource, you can implement <strong class="markup--strong markup--p-strong">your own reconciler and autoscaling system</strong> without changing anything else about the Knative Serving system. Well, there you go!</p>

<p name="b5d8" id="b5d8" class="graf graf--p graf-after--p">A quick copy of a Kubernetes sample-controller and you’ve implemented a reconciler that operates on your own class of Knative PodAutoscaler. It queries upstream metrics to scale predictively.</p>

<p name="7af8" id="7af8" class="graf graf--p graf-after--p">This is what you have to change in your Knative Service to wire it up:</p>

<figure name="d26a" id="d26a" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 465px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-width="2012" data-height="1336" src="/blog/articles/images/1_Ec5KvL9ux3AvlMFJ6liiDw.png">

</div>

</figure>

<p name="ddb3" id="ddb3" class="graf graf--p graf-after--figure">Wow. Controllers and autoscalers are hard to write. But it’s a core problem for your business and you’ve got it up and running. And you didn’t have to touch all the other stuff that wasn’t related to this particular autoscaling problem. As you think on how Knative has grown with your business over the last couple years, you just gotta say “I got options, but Knative … you’re the top one!”</p>

<h3 name="b13d" id="b13d" class="graf graf--h3 graf-after--p">What happened?</h3>

<p name="98d5" id="98d5" class="graf graf--p graf-after--h3">To learn more about how the PodAutoscaler works and the options that Knative autoscaling has, please watch the Kubecon talk <a href="https://youtu.be/OPSIPr-Cybs" data-href="https://youtu.be/OPSIPr-Cybs" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Knative: Scaling From 0 to Infinity</a> and checkout the code on <a href="https://github.com/josephburnett/kubecon18" data-href="https://github.com/josephburnett/kubecon18" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Github</a>. Or play around with the Knative Serving <a href="https://knative.dev/docs/serving/autoscaling/autoscale-go/" target="_blank">autoscaling sample</a>.</p>

<p name="2ee4" id="2ee4" class="graf graf--p graf-after--p">This is where the PodAutoscaler sits in relation to the other Knative entities:</p>

<figure name="d41a" id="d41a" class="graf graf--figure graf-after--p">

<div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 394px;">

<div class="aspectRatioPlaceholder-fill">

</div>

<img class="graf-image" data-image-id="principled-objects" data-width="960" data-height="540" data-is-featured="true" src="/blog/images/principled-objects.png">

</div>

</figure>

<p name="f11d" id="f11d" class="graf graf--p graf--empty graf-after--figure graf--trailing">

<br>

</p>

</div>

</div>

</section>

</section>

<footer>

<p>

<a href="https://medium.com/p/e32a27b7855">View original.</a>

</p>

<p>Exported from <a href="https://medium.com">Medium</a> on March 27, 2019.</p>

</footer>
