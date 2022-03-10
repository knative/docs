---
Title: "End Users and Knative"
Author: "[Murugappan Chetty](https://github.com/itsmurugappan)"
Author handle: https://twitter.com/itsmurugappan
date: 2022-03-08
description: Knative from the lens of an end user
folder with media files: "images/enduser"
blog URL: "https://itsmurugappan.medium.com"
labels: Article
type: "blog"
---

**_Author: [Murugappan Chetty](https://twitter.com/itsmurugappan) (Optum,
representing end users @ Knative Steering Committee)_**

Knative is an open-source community that values end-user
contributions/interactions highly, this is evident in PRs, monthly meetups,
slack interactions, etc. To top it all, recently Knative opened an end-user seat
in the Steering Committee. This is very significant for a couple of reasons

- Instills confidence in end-user organizations to use Knative in production
- Very few OSS communities have end-user representation in the steering
  committee

I am pleased to share that I have been elected as the first end-user
representative in the Steering Committee. In this blog, I would like to share my
organization’s Knative experience so far.

## Why Knative?

First things first, Knative was not picked for being the next shiny object. The
whole process was organic. The following factors led to the need for a
Kubernetes abstraction.

- Mature container ecosystem.
- Serverless workloads
- Need for better developer experience than vanilla Kubernetes (deployment +
  service + ingress + ...)

The situation was ripe for building a new platform on top of Kubernetes. Before
doing that we wanted to check if we could leverage an existing open-source
solution, there were a handful of them at various maturity levels, Knative was
the one that stood out for us

- Best scaling performance compared to all its peers.
- Developer experience (single Knative service resource yields Kubernetes
  deployment + service + ingress + certificate + custom domain).
- Robust Primitives for building a developer platform.
- OSS Community with a good governance model
- Backed by multiple vendors
- Great support for an open and free project

## Implementation

To cater to developers with varying skill levels we built an abstraction on top
of Knative. This layer kept the barrier of entry low for new users and could be
bypassed for advanced users. We also built components to integrate with our
enterprise applications. The below pictures shows our deployment model and
integrations we have built in-house.

![Platform Architecture](/blog/steering/images/enduser-platform-architecture.png)

![Enterprise Integration](/blog/steering/images/enduser-enterprise-integration.png)

With the above deployment model and integrations, we were able to give clean
code to URL experience for our internal users. With just a few params,
developers were able to deploy their services and receive a TLS enabled URL in
seconds.

## Interaction with Community

Two years since our first Knative service deployment, our platform has grown at
a rapid pace serving hundreds of developers. This would not have been possible
without the Knative community support. There are various avenues to interact
with the community.

### Slack

To this day, there is no slowing down the momentum in the slack channels, most
concerns get addressed almost immediately. Slack is the place to get started on
Knative.

### Hacky Hours

If you ask me to choose the best experience of Knative so far, weekly hacky
hours would be on the top. These casual/virtual meetups used to be on Friday
afternoons. Every week there were several 'aha' moments with demos by Knative
maintainers/contributors/end-users. In these meetings, I could get 1 on 1 with
the who's who of Knative and validate our implementations.

### Monthly Meetups

Hacky hours might have been paused, for now, monthly meetups do happen every
month. This is a great place to know the project TLDR and some neat use case
demos.
[I had the privilege of showcasing our Knative implementation here.](https://www.youtube.com/watch?v=dfWZRXtVa6M&list=PLnPNqTSUj2hKH5W7GWOZ-mzcw4r3O4bHj&index=3)
There is no better way to validate an implementation than giving a talk at a
meetup/conference. For end-users, I definitely recommend demo'ing the solutions
here.

## Contributions

During our implementation, we did hit some hiccups and some missing features,
which gave us the chance to open PRs and contribute upstream. The maintainers
were receptive to our issues and most of them got merged, for the ones that
didn’t there were valid reasons and good discussions around them to learn. I
have contributed to most of the repos, but some of my significant contributions
are to client repo where I was eventually elevated to a reviewer.

Apart from upstream contributions, we have built
[custom Knative channel](https://github.com/optum/kafka-topic-channel)
implementation and
[Knative event sources](https://github.com/itsmurugappan/gql-source) and
open-sourced under our GitHub org.

Our Knative implementation gave me the opportunity to
[speak at conferences](https://www.youtube.com/playlist?list=PLnPNqTSUj2hKH5W7GWOZ-mzcw4r3O4bHj).
Most significant being Kubecon and IstioCon. Now with
[Knative in CNCF](https://knative.dev/blog/steering/cncf/), it should open more
doors for the end-users to share their story at Kubecon.

## Closing Thoughts

In closing thoughts, I would like to share what Knative has been for me. A
couple of years ago, I started experimenting with Knative not knowing that I
would be on the Knative Steering Committee one day. I have not contributed to
every single OSS project out there but have been part of various communities,
raising issues, providing feedback, being on the slack channel, etc., with that
experience I can confidently say being part of this community has been rewarding
on every front. It wouldn’t be an exaggeration to say that Knative has been one
of my driving forces during these covid times.

![My Knative Timeline](/blog/steering/images/enduser-timeline.png)
