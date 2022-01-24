# Getting Started with Knative

This tutorial will guide you through using some of the most commonly used features in Knative.

For Knative Serving you will create a Service, scale your Service, and then split
traffic between two revisions of the Service.
For Knative Eventing you will learn about Brokers, create a Source, and create a Trigger.
It is recommended that you complete the topics in this tutorial in order.

## Before you begin

Before you start this tutorial, you must Install Knative Serving and Knative Eventing.
Choose one of the following:

- **Quickstart installation:** You can install a local distribution of Knative for development use by following the [Knative Quickstart installation](quickstart-install.md).

- **Manual installation:** Alternatively, you can install Knative
[using YAML](../install/yaml-install/README.md) or
[using the Operator](../install/operator/knative-with-operators.md).
These methods take longer than quickstart, but are suitable for production and
enable you to  customize your installation.
If you install manually, you must install the following configuration for this tutorial:
    - For Knative Serving:
        - Kourier networking layer
        - Magic DNS
    - For Knative Eventing:
        - In-Memory default Channel
        - MT-Channel-based Broker
