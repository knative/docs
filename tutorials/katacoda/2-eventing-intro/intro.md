## What is Knative?
Knative brings "serverless" experience to kubernetes. It also tries to codify common patterns and best practices for
running applications while hiding away the complexity of doing that on kubernetes. It does so by providing two
components:
- Eventing - Management and delivery of events
- Serving - Request-driven compute that can scale to zero

## What will we learn in this tutorial?
With Knative Serving, we have a powerful tool which can take our containerized code and deploy it with relative ease. 
With Knative Eventing, you gain a few new super powers 🚀 that allow you to build Event-Driven Applications.
> **What are Event Driven Applications?**
> Event-driven applications are designed to detect events as they occur, and then deal with them using some 
> event-handling procedure. Producing and consuming events with an "event-handling procedure" is precisely what 
> Knative Eventing enables.
> Want to find out more about Event-Driven Architecture and Knative Eventing? Check out this CNCF Session 
> aptly named "[Event-driven architecture with Knative events](https://www.cncf.io/online-programs/event-driven-architecture-with-knative-events/)"