# About ApiServerSource

![stage](https://img.shields.io/badge/Stage-stable-green?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

The API server source is a Knative Eventing Kubernetes custom resource that listens for events emitted by the
Kubernetes API server (eg. pod creation, deployment updates, etc...) and forwards them as CloudEvents to a sink.

The API server source is part of the core Knative Eventing component, and is provided by default when Knative Eventing is installed. Multiple instances of an ApiServerSource object can be created by users.
