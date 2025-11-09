# Getting Started with Knative

Welcome! This guide helps you get started with Knative based on your goals and experience level.

## What is Knative?

Knative is a Kubernetes-based platform for deploying and managing serverless workloads. It provides components for building, deploying, and running applications that automatically scale, including scaling to zero when idle.

## Choose Your Path

### I want to try Knative quickly

**Perfect for:** Developers who want hands-on experience

Follow our step-by-step tutorial:

1. [Install Knative locally](quickstart-install.md) - Set up using kind or minikube (10 minutes)
2. [Deploy your first service](first-service.md) - Create and test a simple application
3. [Explore autoscaling](first-autoscale.md) - See how Knative scales your app
4. [Clean up](clean-up.md) - Remove the local installation

**Prerequisites:** Docker, kubectl, 3 CPUs, 3 GB RAM

---

### I want to understand Knative first

**Perfect for:** Evaluators and decision makers

- [What is Knative?](which-knative.md) - Overview of components and use cases
- [About Knative Functions](about-knative-functions.md) - Simplified function development
- [Documentation overview](../README.md) - Navigate all Knative docs

Then proceed to the [installation options](../install/) for production deployments.

---

### I want to explore event-driven features

**Perfect for:** Building event-driven applications

1. [Getting started with Eventing](getting-started-eventing.md) - Introduction to event-driven architecture
2. [Create an event source](first-source.md) - Generate events
3. [Set up a broker](first-broker.md) - Route events to services
4. [Configure triggers](first-trigger.md) - Filter and deliver events

---

### I want to build serverless functions

**Perfect for:** Function-as-a-Service development

1. [Install the func CLI](install-func.md) - Set up the functions CLI
2. [Create a function](create-a-function.md) - Build your first function
3. [Build and deploy](build-run-deploy-func.md) - Deploy to Knative

---

## What's Next?

After completing the getting started tutorials:

- [Next steps](next-steps.md) - Continue your Knative journey
- [Traffic splitting](first-traffic-split.md) - Implement canary deployments
- [Code samples](../samples/) - Explore real-world examples
- [Complete tutorial](tutorial.md) - End-to-end application walkthrough

---

## Components Overview

**Knative Serving** - Deploy HTTP applications with automatic scaling and traffic management

**Knative Eventing** - Build event-driven applications using CloudEvents

**Knative Functions** - Create functions without managing containers or Kubernetes

---

## Need Help?

- **Slack:** [#knative-users](https://cloud-native.slack.com/) on CNCF Slack
- **Issues:** [Report problems](https://github.com/knative/docs/issues)
- **Community:** [Join working groups](../community/)

---

## Installation for Production

For production deployments, see:
- [YAML installation](../install/yaml-install/) - Direct kubectl installation
- [Operator installation](../install/operator/) - Automated lifecycle management
- [Platform-specific guides](../install/) - Cloud provider installations

**Requirements:** Kubernetes 1.28+, cluster admin access