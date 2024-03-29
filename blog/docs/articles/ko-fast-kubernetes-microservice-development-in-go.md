# ko: fast Kubernetes microservice development in Go

**Author: [Matt Moore](https://twitter.com/mattomata), Founder/CTO @ Chainguard**

  <article class="h-entry">
    <section data-field="body" class="e-content">
      <section name="f298" class="section section--body section--first section--last">
        <div class="section-content">
          <div class="section-inner sectionLayout--insetColumn">
            <p name="23c9" id="23c9" class="graf graf--p graf-after--h3">
              <em class="markup--em markup--p-em">I originally wrote </em>
              <code class="markup--code markup--p-code">ko</code>
              <em class="markup--em markup--p-em"> to help Knative developers. I was prompted to write this introductory post by the positive feedback from the community, including an IBM booth talk on </em>
              <code class="markup--code markup--p-code">ko</code>
              <em class="markup--em markup--p-em"> during recent Kubecon Seattle 2018. I hope you enjoy using </em>
              <code class="markup--code markup--p-code">ko</code>
              <em class="markup--em markup--p-em"> as much as we do, and I look forward to your feedback on </em>
              <a href="https://slack.knative.dev/" data-href="https://slack.knative.dev" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">
                <em class="markup--em markup--p-em">slack.knative.dev</em>
              </a>
              <em class="markup--em markup--p-em">.</em>
            </p>
            <p name="33fe" id="33fe" class="graf graf--p graf-after--p">Over the past few years, there has been a lot of hype about containers. Docker, Kubernetes and related technology have taken the public cloud by storm (pun intended). At the same time, it seems, as software projects grow increasingly more complex, so too does the development process.</p>
            <p name="f9cf" id="f9cf" class="graf graf--p graf-after--p">
              <strong class="markup--strong markup--p-strong">What starts as:</strong>
            </p>
            <figure name="3e51" id="3e51" class="graf graf--figure graf-after--p">
              <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 191px;">
                <div class="aspectRatioPlaceholder-fill">
                </div>
                <div data-width="884" data-height="241" data-action="zoom" data-scroll="native">
                  <img src="/blog/articles/images/singleservice.png">
                </div>
              </div>
            </figure>
            <p name="e2b9" id="e2b9" class="graf graf--p graf-after--figure">
              <strong class="markup--strong markup--p-strong">Quickly becomes:</strong>
            </p>
            <figure name="487b" id="487b" class="graf graf--figure graf-after--p">
              <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 247px;">
                <div class="aspectRatioPlaceholder-fill">
                </div>
                <div data-width="976" data-height="344" data-action="zoom" data-scroll="native">
                  <img src="/blog/articles/images/multipleservices.png">
                </div>
              </div>
            </figure>
            <p name="f0f9" id="f0f9" class="graf graf--p graf-after--figure">Tools such as <a href="https://github.com/googlecontainerTools/skaffold" data-href="https://github.com/googlecontainerTools/skaffold" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">skaffold</a> can wrap this process for arbitrary languages and Dockerfiles to make it easier to manage (and faster), but you still need to write <a href="https://xitonix.io/containerised-go-services/" data-href="https://xitonix.io/containerised-go-services/" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">
              <em class="markup--em markup--p-em">artisanal hand-crafted Dockerfiles</em>
            </a>, and typically need to write <em class="markup--em markup--p-em">more</em> yaml (or other) to tell the tooling how to orchestrate this (e.g. what gets pushed where?):</p>
            <figure name="890d" id="890d" class="graf graf--figure graf-after--p">
              <div class="aspectRatioPlaceholder is-locked" style="max-width: 700px; max-height: 354px;">
                <div class="aspectRatioPlaceholder-fill">
                </div>
                <div data-width="944" data-height="477" data-action="zoom" data-scroll="native">
                  <img src="/blog/articles/images/scaffold.png">
                </div>
              </div>
            </figure>
            <p name="60fe" id="60fe" class="graf graf--p graf-after--figure">
              <code class="markup--code markup--p-code">ko</code>
              <strong class="markup--strong markup--p-strong"> takes a different approach that leans into Go idioms to eliminate configuration.</strong>
            </p>
            <p name="295b" id="295b" class="graf graf--p graf-after--p">One such Go idiom is that binaries are referenced by “<a href="https://golang.org/doc/code.html#ImportPaths" data-href="https://golang.org/doc/code.html#ImportPaths" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">import paths</a>”; a typical way of installing a Go binary would be:</p>
            <pre name="c44e" id="c44e" class="graf graf--pre graf-after--p"># e.g. installing ko itself<br>go get github.com/google/go-containerregistry/cmd/ko</pre>
            <p name="2114" id="2114" class="graf graf--p graf-after--pre">Getting started with <code class="markup--code markup--p-code">ko</code> does not take any additional configuration files, you simply replace references to container images with import paths:</p>
            <pre name="9af3" id="9af3" class="graf graf--pre graf-after--p"># This example is based on:<br># <a href="https://github.com/google/ko/blob/master/cmd/ko/test/test.yaml" target="_blank">https://github.com/google/ko/blob/master/cmd/ko/test/test.yaml</a>
              <br>apiVersion: v1<br>kind: Pod<br>metadata:<br>  name: kodata<br>spec:<br>  containers:<br>  - name: test<br>    # ko builds and publishes this Go binary, and replaces this<br>    # with an image name.<br>    image: github.com/google/go-containerregistry/cmd/ko/test<br>  restartPolicy: Never</pre>
              <p name="b28f" id="b28f" class="graf graf--p graf-after--pre">That’s it.</p>
              <p name="7e1e" id="7e1e" class="graf graf--p graf-after--p">
                <strong class="markup--strong markup--p-strong">How do I consume this with </strong>
                <code class="markup--code markup--p-code">ko</code>
                <strong class="markup--strong markup--p-strong">?</strong>
              </p>
              <p name="ec8c" id="ec8c" class="graf graf--p graf-after--p">
                <code class="markup--code markup--p-code">ko</code> also needs to know where the user wants to publish their images. This is defined outside of the yaml manifest as generally each developer on your team will use their own.</p>
                <p name="d4f3" id="d4f3" class="graf graf--p graf-after--p">For example, developing on Knative, I use this in my&nbsp;<code class="markup--code markup--p-code">.bashrc</code> file:</p>
                <pre name="2fb5" id="2fb5" class="graf graf--pre graf-after--p">export KO_DOCKER_REPO=gcr.io/mattmoor-private/ko</pre>
                <p name="ffa1" id="ffa1" class="graf graf--p graf-after--pre">
                  <em class="markup--em markup--p-em">NOTE: for DockerHub users (and possibly others), this should be: </em>
                  <code class="markup--code markup--p-code">docker.io/username</code>
                  <em class="markup--em markup--p-em"> as DockerHub does not support multi-level repository names.</em>
                </p>
                <p name="9850" id="9850" class="graf graf--p graf-after--p">After that, the command-line interface is modeled after <code class="markup--code markup--p-code">kubectl</code>:</p>
                <pre name="f438" id="f438" class="graf graf--pre graf-after--p">ko apply -f directory/ -f file.yaml</pre>
                <p name="7f81" id="7f81" class="graf graf--p graf-after--pre">This will have the same net effect as <code class="markup--code markup--p-code">kubectl apply</code>, but it will also build, containerize, and publish the Go microservices referenced from the yamls as well, with significantly less configuration:</p>
                <figure name="98dd" id="98dd" class="graf graf--figure graf-after--p">
                  <div class="aspectRatioPlaceholder is-locked" style="max-width: 673px; max-height: 469px;">
                    <div class="aspectRatioPlaceholder-fill">
                    </div>
                  <div data-width="673" data-height="469" data-action="zoom" data-scroll="native">
                    <img src="/blog/articles/images/koservices.png">
                  </div>
                  </div>
                </figure>
                <p name="6c5e" id="6c5e" class="graf graf--p graf-after--figure">You only write Kubernetes yamls and code. No Dockerfiles, no Makefiles. You run one command and your latest code is running.</p>
                <p name="05d4" id="05d4" class="graf graf--p graf-after--p">Following the above example (trimmed for width):</p>
                <pre name="d031" id="d031" class="graf graf--pre graf-after--p">~/go/src/github.com/google/go-containerregistry<br>$ ko apply -f cmd/ko/test/test.yaml <br>Using base .. for github.com/google/go-containerregistry/cmd/ko/test<br>Publishing gcr.io/mattmoor-public/test-01234abcd:latest<br>mounted blob: sha256:deadbeef<br>mounted blob: sha256:baadf00d<br>pushed blob sha256:deadf00d<br>pushed blob sha256:baadbeef<br>pushed blob sha256:beeff00d<br>gcr.io/mattmoor-public/test-01234abcd:latest: digest: ... size: 915<br>Published gcr.io/mattmoor-public/test-01234abcd@...<br>pod/kodata created</pre>
                <pre name="7e57" id="7e57" class="graf graf--pre graf-after--pre">~/go/src/github.com/google/go-containerregistry$ kubectl get pods<br>NAME     READY   STATUS      RESTARTS   AGE<br>kodata   0/1     Completed   0          1</pre>
                <p name="ca88" id="ca88" class="graf graf--p graf-after--pre">
                  <strong class="markup--strong markup--p-strong">Just the image</strong>
                </p>
                <p name="faaa" id="faaa" class="graf graf--p graf-after--p">The simplest trick that <code class="markup--code markup--p-code">ko</code> supports is to simply containerize and publish an image. One neat thing about this is that it works with most Go binaries without any knowledge of <code class="markup--code markup--p-code">ko</code>.</p>
                <p name="a1ee" id="a1ee" class="graf graf--p graf-after--p">For example (trimmed for width):</p>
                <pre name="d560" id="d560" class="graf graf--pre graf-after--p">~/go/src/golang.org/x/tools<br>$ ko publish ./cmd/goimports/<br>Using base .. for golang.org/x/tools/cmd/goimports<br>Publishing gcr.io/mattmoor-public/goimports-01234:latest<br>mounted blob: sha256:deadbeef<br>mounted blob: sha256:baadf00d<br>mounted blob: sha256:deadf00d<br>pushed blob sha256:baadbeef<br>pushed blob sha256:beeff00d<br>gcr.io/mattmoor-public/goimports-01234:latest: digest: ... size: 914<br>Published gcr.io/mattmoor-public/goimports-01234@...</pre>
                <p name="7282" id="7282" class="graf graf--p graf-after--pre">
                  <code class="markup--code markup--p-code">ko</code>
                  <strong class="markup--strong markup--p-strong"> is for releases too!</strong>
                </p>
                <p name="bf39" id="bf39" class="graf graf--p graf-after--p">You can also use <code class="markup--code markup--p-code">ko</code> to publish things for redistribution via:</p>
                <pre name="5309" id="5309" class="graf graf--pre graf-after--p"># This does everything `apply` does except it pipes to<br># stdout instead of kubectl<br>ko resolve -f config/ &gt; release.yaml</pre>
                <pre name="8b07" id="8b07" class="graf graf--pre graf-after--pre"># Later...<br>kubectl apply -f release.yaml</pre>
                <p name="dec5" id="dec5" class="graf graf--p graf-after--pre">For example, we use this to release all of the Knative components.</p>
                <p name="d074" id="d074" class="graf graf--p graf-after--p">
                  <strong class="markup--strong markup--p-strong">Try it out, and tell us what you think.</strong>
                </p>
                <p name="20d1" id="20d1" class="graf graf--p graf-after--p">This just scratches the surface of what you can do with <code class="markup--code markup--p-code">ko</code>, and what <code class="markup--code markup--p-code">ko</code> does for you. For more information check out the <a href="https://github.com/google/go-containerregistry/blob/master/cmd/ko/README.md" data-href="https://github.com/google/go-containerregistry/blob/master/cmd/ko/README.md" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">README.md</a>. If you have questions: #ko on <a href="https://slack.knative.dev/" data-href="https://slack.knative.dev" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">slack.knative.dev</a>, or reach me on <a href="https://twitter.com/mattomata" data-href="https://twitter.com/mattomata" class="markup--anchor markup--p-anchor" rel="nofollow noopener" target="_blank">Twitter @mattomata</a>.</p>
                <p name="3bc2" id="3bc2" class="graf graf--p graf-after--p">
                  <strong class="markup--strong markup--p-strong">Some Common Pitfalls</strong>
                </p>
                <p name="0941" id="0941" class="graf graf--p graf-after--p">A couple of things to be careful of with ko because of how heavily it relies on convention:</p>
                <ol class="postList">
                  <li name="184e" id="184e" class="graf graf--li graf-after--p">
                    <strong class="markup--strong markup--li-strong">You need to be on </strong>
                    <code class="markup--code markup--li-code">
                      <strong class="markup--strong markup--li-strong">${GOPATH}</strong>
                    </code> or it will not know what package you are in.</li>
                    <li name="11b1" id="11b1" class="graf graf--li graf-after--li graf--trailing">
                      <strong class="markup--strong markup--li-strong">Typos are the worst.</strong> Because <code class="markup--code markup--li-code">ko</code> is insensitive to schemas, it will ignore any string that is not the import path of a “main” package, so if you have a simple typo in your import path then it will be left as is and you will likely see your Pod <code class="markup--code markup--li-code">ErrImagePull</code>.</li>
                </ol>
              </div>
            </div>
          </section>
      </section>
      <footer>
        <p>By <a href="https://medium.com/@mattmoor" class="p-author h-card">Matthew Moore</a> on <a href="https://medium.com/knative/ko-fast-kubernetes-microservice-development-in-go-f94a934a7240">
          <time class="dt-published">December 18, 2018</time>
        </a>.</p>
      </footer>
    </article>
