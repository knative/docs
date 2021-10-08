# User registration example based on Serverless Workflow

## Overview

this is an example showing workflow as a function flow use case. It implements common scenario for serverless usage where
individual functions builds up a complete business case. In this example it is a simple user registration
that performs various checks and registers users in the Swagger PetStore service.

This examples illustrates how a workflow is sliced into functions that are composed into a function flow based on
the actual logic steered by the workflow definition. Yet each function can be invoked at anytime making the workflow to
act as a definition that can start at any place and continue according to defined flow of activities aka functions.

This example is built using [BPMN2 (Business process modeling and notiation)](https://www.bpmn.org) specification as the DSL of the workflow

See complete description of this example [here](https://automatikio.com/component-main/0.0.0/examples/userregistration.html)

## Run it

To run this example on either Knative or Google Cloud Run follow steps described [here](../index.md)
