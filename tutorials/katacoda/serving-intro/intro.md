## What is Knative?
Knative brings "serverless" experience to kubernetes. It also tries to codify common patterns and best practises for running applications while hiding away the complexity of doing that on kubernetes. It does so by providing two components:
- Eventing - Management and delivery of events
- Serving - Request-driven compute that can scale to zero

## What will we learn in this tutorial?
This tutorial will serve as an introduction to Knative. Here we will install Knative (Serving only), deploy an application, watch Knative's "scale down to zero" feature then deploy a second version of the application and watch traffic split between the two versions.
