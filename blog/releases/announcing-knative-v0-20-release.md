---
title: "Version v0.20 release"
linkTitle: "Version v0.20 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-01-15
description: "Knative v0.20 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.20 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.20](#serving-v020)
- [Eventing v0.20](#eventing-v020)
- Eventing Extensions
    - [Eventing Kafka Broker v0.20](#eventing-kafka-broker-v020)
    - [Eventing Gitlab v0.20](#eventing-gitlab-v020)
    - [Eventing RabbitMQ v0.20](#eventing-rabbitmq-v020)
- [CLI v0.20](#client-v020)
- [Operator v0.20](#operator-v020)
- [Thank you contributors v0.20](#thank-you-contributors-v0.20)


### Highlights

-

### Serving v0.20

🚨 Breaking

💫 New Features & Changes

🐞 Bug Fixes

### Eventing v0.20

💫 New Features & Changes

🐞 Bug Fixes

🧹 Clean up


### Eventing Contributions v0.20

#### Eventing Kafka Broker v0.20

Release Notes for [eventing-kafka-broker](https://github.com/knative-sandbox/eventing-kafka-broker)

**Actions Required (pre-upgrade)**
- Run `kubectl delete configmap -n knative-eventing kafka-broker-brokers-triggers`

🚨 Breaking

💫 New Features & Changes

🐞 Bug Fixes

🧹 Clean up


#### Eventing Gitlab v0.20

Release Notes for [eventing-gitlab](https://github.com/knative-sandbox/eventing-gitlab)

💫 New Features & Changes

🐞 Bug Fixes

🧹 Clean up


#### Eventing RabbitMQ v0.20

Release Notes for [eventing-rabbitmq](https://github.com/knative-sandbox/eventing-rabbitmq)

💫 New Features & Changes

🐞 Bug Fixes

🧹 Clean up


### Client v0.20

-

🚨 Breaking


💫 New Features & Changes


#### Other CLI Features


### Operator v0.20

The new operator can now deploy the new version `v0.20` of serving and eventing components.

🐞 Bug Fixes

🧹 Clean up

### Thank you contributors v0.20

- [@antoineco](https://github.com/antoineco)
- [@daisy-ycguo](https://github.com/daisy-ycguo)
- [@danielhelfand](https://github.com/danielhelfand)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@eclipselu](https://github.com/eclipselu)
- [@houshengbo](https://github.com/houshengbo)
- [@ian-mi](https://github.com/ian-mi)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@joshuawilson](https://github.com/joshuawilson)
- [@julz](https://github.com/julz)
- [@lberk](https://github.com/lberk)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mattmoor](https://github.com/mattmoor)
- [@matzew](https://github.com/matzew)
- [@n3wscott](https://github.com/n3wscott)
- [@nak3](https://github.com/nak3)
- [@navidshaikh](https://github.com/navidshaikh)
- [@pierDipi](https://github.com/pierDipi)
- [@rhuss](https://github.com/rhuss)
- [@runzexia](https://github.com/runzexia)
- [@sheetalsingala](https://github.com/sheetalsingala)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@taragu](https://github.com/taragu)
- [@vaikas](https://github.com/vaikas)
- [@whaught](https://github.com/whaught)
- [@yanweiguo](https://github.com/yanweiguo)
- [@zroubalik](https://github.com/zroubalik)





### Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/community/) can use, improve, and enjoy. We'd love you to join us!

- [Welcome to Knative](https://knative.dev/docs#welcome-to-knative)
- [Getting started documentation](https://knative.dev/docs/#getting-started)
- [Samples and demos](https://knative.dev/docs#samples-and-demos)
- [Knative meetings and work groups](https://knative.dev/contributing/#working-group)
- [Questions and issues](https://knative.dev/contributing/#questions-and-issues)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
