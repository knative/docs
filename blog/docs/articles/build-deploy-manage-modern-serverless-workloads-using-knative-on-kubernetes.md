# Serverless workloads using Knative

**Author: [Mark Chmarny](https://twitter.com/mchmarny), TL for Cloud OSS @Google**

**Date: 2018-11-14**

  <article class="h-entry">
    <section data-field="description" class="p-summary">
      By now, Kubernetes should be the default target for your deployments. Yes, there are still use-cases where Kubernetes is not the optimal…
    </section>
    <section data-field="body" class="e-content">
      <section name="f298" class="section section--body section--first section--last">
        <div class="section-divider">
          <hr class="section-divider">
        </div>
        <div class="section-content">
          <div class="section-inner sectionLayout--insetColumn">
            <p name="6981" id="6981" class="graf graf--p graf-after--h3">By now, <a href="https://kubernetes.io/" data-href="https://kubernetes.io/" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Kubernetes</a> should be the default target for your deployments. Yes, there are still use-cases where Kubernetes is not the optimal choice, but these represent an increasingly smaller number of modern workloads.</p>
            <p name="c063" id="c063" class="graf graf--p graf-after--p">The main value of Kubernetes is that it greatly abstracts much of the infrastructure management pain. The broad support amongst virtually all major Cloud Service Providers (CSP) also means that your workloads are portable. Combined with the already vibrant ecosystem of Kubernetes-related tools, means that the experience of the operator, the person responsible for managing Kubernetes, is now pretty smooth.</p>
            <blockquote name="c1ac" id="c1ac" class="graf graf--blockquote graf-after--p">But what about the experience of the developer, the person who builds solutions on top of Kubernetes?</blockquote>
            <p name="09a5" id="09a5" class="graf graf--p graf-after--blockquote">Despite what some might tell you, Kubernetes is not yet today’s application server. For starters, the act of developing, deploying and managing services on Kubernetes is still too complicated. Yes, there are many open source projects for logging, monitoring, integration, etc., but, even if you put these together just right, the experience of developing on Kubernetes is still fragile and way too labour-intensive.</p>
            <p name="1312" id="1312" class="graf graf--p graf-after--p">As if that wasn’t enough, the growing popularity of functions as the atomic unit of code development further contributes to the overall complexity. Often creating different development patterns on two disconnected surface areas:one for functions (FaaS) and one for applications (PaaS).</p>
            <p name="3f53" id="3f53" class="graf graf--p graf-after--p">As the result, developers today are being forced to worry about infrastructure-related concerns: such as, image building, registry publishing, deployment services, load balancing, logging, monitoring, and scaling. However, what all they really want to do is write code.</p>
            <h3 name="33f0" id="33f0" class="graf graf--h3 graf-after--p">Introducing Knative</h3>
            <figure name="69ac" id="69ac" class="graf graf--figure graf--layoutOutsetLeft graf-after--h3">
              <div class="aspectRatioPlaceholder is-locked" style="max-width: 410px; max-height: 322px;">
                <div class="aspectRatioPlaceholder-fill">
                </div>
                <img class="graf-image" data-image-id="knative.png" data-width="410" data-height="322" src="/blog/images/knative.png">
              </div>
            </figure>
            <p name="aa9b" id="aa9b" class="graf graf--p graf-after--figure">At Google Cloud Next in San Francisco this week, Google announced an early preview of the GKE serverless add-on (<a href="http://g.co/serverlessaddon" data-href="http://g.co/serverlessaddon" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">g.co/serverlessaddon</a>). Google also open-sourced Knative (kay-nay-tiv), the project that powers the serverless add-on (<a href="https://github.com/knative" data-href="https://github.com/knative" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">github.com/knative</a>).</p>
            <p name="7c8f" id="7c8f" class="graf graf--p graf-after--p">Knative implements many of the learnings from Google. The open source project already has contributions from companies like Pivotal, IBM, Red Hat and SAP and collaboration with open-source Function-as-a-Service framework communities like <a href="https://github.com/apache/incubator-openwhisk" data-href="https://github.com/apache/incubator-openwhisk" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">OpenWhisk</a>, <a href="https://github.com/projectriff/riff" data-href="https://github.com/projectriff/riff" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">riff</a>, and <a href="https://github.com/kyma-project" data-href="https://github.com/kyma-project" class="markup--anchor markup--p-anchor" rel="noopener" target="_blank">Kyma</a> who either replatform on to Knative or consume one or more components from the Knative project.</p>
            <figure name="ca72" id="ca72" class="graf graf--figure graf-after--p">
              <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 440px;">
                <div class="aspectRatioPlaceholder-fill">
                </div>
                <img class="graf-image" data-image-id="0*v-wKOVy6dsJdbABA" data-width="1600" data-height="1005" data-is-featured="true" src="/blog/images/audience.png">
              </div>
              <figcaption class="imageCaption">Knative audience</figcaption>
            </figure>
            <blockquote name="15c2" id="15c2" class="graf graf--blockquote graf-after--figure">Knative helps developers build, deploy, and manage modern serverless workloads on Kubernetes.</blockquote>
            <p name="b4e2" id="b4e2" class="graf graf--p graf-after--blockquote">It provides a set of building blocks that enable modern, source-centric and container-based development workloads on Kubernetes:</p>
            <ul class="postList">
              <li name="5f0a" id="5f0a" class="graf graf--li graf-after--p">
                <a href="https://github.com/knative/build" data-href="https://github.com/knative/build" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Build</a> — Source-to-container build orchestration</li>
                <li name="c06f" id="c06f" class="graf graf--li graf-after--li">
                  <a href="https://github.com/knative/eventing" data-href="https://github.com/knative/eventing" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Eventing</a> — Management and delivery of events</li>
                  <li name="b148" id="b148" class="graf graf--li graf-after--li">
                    <a href="https://github.com/knative/serving" data-href="https://github.com/knative/serving" class="markup--anchor markup--li-anchor" rel="noopener" target="_blank">Serving</a> — Request-driven compute that can scale to zero</li>
                  </ul>
                  <p name="abed" id="abed" class="graf graf--p graf-after--li">Knative documentation provides instructions on <a href="../../../../../docs/install/">how to install</a> it on hosted Kubernetes offering like <a href="../../../../../docs/install/knative-with-gke">Google Cloud Platform</a> or <a href="../../../../../docs/install/knative-with-iks">IBM</a>, and on-prem Kubernetes installations, like the one offered by <a href="../../../../../docs/install/knative-with-pks">Pivotal</a>. Finally, Knative repository also includes <a href="../../../../../docs/install/getting-started-knative-app">samples and how-to instructions</a> to get you started developing on Kubernetes.</p>
                  <h3 name="0113" id="0113" class="graf graf--h3 graf-after--p">Knative Overview</h3>
                  <p name="e295" id="e295" class="graf graf--p graf-after--h3">Knative is based on the premise of clear separation of concerns. It allows developers and operators to reason about the workload development, deployment, and management by defining primitive objects in a form of Custom Resource Definitions (CRDs) which extend on the object model found in Kubernetes.</p>
                  <figure name="de3e" id="de3e" class="graf graf--figure graf-after--p">
                    <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 431px;">
                      <div class="aspectRatioPlaceholder-fill">
                      </div>
                      <img class="graf-image" data-image-id="0*hfyRGyNWNFycw5bx" data-width="740" data-height="456" src="/blog/images/primitive-objects.png">
                    </div>
                    <figcaption class="imageCaption">Knative defines primitives with clear separation of concerns</figcaption>
                  </figure>
                  <ul class="postList">
                    <li name="2cb6" id="2cb6" class="graf graf--li graf-after--figure">
                      <strong class="markup--strong markup--li-strong">Configuration</strong> — is the desired state for your service, both code and configuration</li>
                      <li name="5be3" id="5be3" class="graf graf--li graf-after--li">
                        <strong class="markup--strong markup--li-strong">Revision</strong> — represents an immutable point-in-time snapshot of your code and configuration</li>
                        <li name="8193" id="8193" class="graf graf--li graf-after--li">
                          <strong class="markup--strong markup--li-strong">Route</strong> — assigns traffic to a revision or revisions of your service</li>
                          <li name="269b" id="269b" class="graf graf--li graf-after--li">
                            <strong class="markup--strong markup--li-strong">Service </strong>— is the combined lite version of all the above objects to enable simple use cases</li>
                          </ul>
                          <p name="6ed0" id="6ed0" class="graf graf--p graf-after--li">In addition to these objects, Knative also defines principle objects for eventing… you know, because serverless. Knative decouples event producers and consumers and implements CNCF CloudEvents (v0.1) to streamline event processing.</p>
                          <figure name="6396" id="6396" class="graf graf--figure graf-after--p">
                            <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 559px;">
                              <div class="aspectRatioPlaceholder-fill">
                              </div>
                              <img class="graf-image" data-image-id="0*3jjrwXWgze2pPhnm" data-width="762" data-height="608" src="/blog/images/events-model.png">
                            </div>
                            <figcaption class="imageCaption">Knative eventing constructs</figcaption>
                          </figure>
                          <ul class="postList">
                            <li name="dc26" id="dc26" class="graf graf--li graf-after--figure">
                              <strong class="markup--strong markup--li-strong">Event Sources</strong> — represents the producer of events (e.g. GitHub)</li>
                              <li name="4cc7" id="4cc7" class="graf graf--li graf-after--li">
                                <strong class="markup--strong markup--li-strong">Event Types</strong> — describes the types of events supported by the different event sources (e.g. Webhook for the above mentioned GitHub source)</li>
                                <li name="dc2c" id="dc2c" class="graf graf--li graf-after--li">
                                  <strong class="markup--strong markup--li-strong">Event Consumers</strong> — represents the target of your action (i.e. any route defined by Knative)</li>
                                  <li name="2882" id="2882" class="graf graf--li graf-after--li">
                                    <strong class="markup--strong markup--li-strong">Event Feeds</strong> — is the binding or configuration connecting the event types to actions</li>
                                  </ul>
                                  <p name="638e" id="638e" class="graf graf--p graf-after--li">The functional implementation of the Knative object model means that Knative is both easy to start with, but capable enough to address more advanced use cases as the complexity of your solutions increases.</p>
                                  <h3 name="e2f4" id="e2f4" class="graf graf--h3 graf-after--p">Summary</h3>
                                  <p name="5231" id="5231" class="graf graf--p graf-after--h3">I hope this introduction gave you an understanding of the value of Knative. And how the Knative objects streamline development on Kubernetes, regardless if you work on applications or functions.</p>
                                  <p name="ecf2" id="ecf2" class="graf graf--p graf-after--p graf--trailing">Over the next few weeks I will be covering each one of the key Knative usage patterns (image push, blue/green deployment model, source to URL, etc). In each post, I will also provide a sample code to illustrate that pattern and allow you to reproduce them on Knative. I’m super excited to share Knative with you, and I hope you come back to find out more.</p>
                                </div>
                              </div>
                            </section>
                          </section>
                          <footer>
                            <p>By <a href="https://medium.com/@mchmarny_google" class="p-author h-card">Mark Chmarny</a> on <a href="https://medium.com/p/4e6d8604972">
                              <time class="dt-published" datetime="2018-11-14T02:20:46.348Z">November 14, 2018</time>
                            </a>.</p>
                            <p>
                              <a href="https://medium.com/@mchmarny_google/build-deploy-manage-modern-serverless-workloads-using-knative-on-kubernetes-4e6d8604972" class="p-canonical">Canonical link</a>
                            </p>
                            <p>Exported from <a href="https://medium.com">Medium</a> on January 8, 2019.</p>
                          </footer>
                        </article>
