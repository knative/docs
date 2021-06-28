# Getting Started with the Knative "Quickstart" Environment

## Install Knative using the konk script

You can get started with a local deployment of Knative by using _Knative on Kind_ (`konk`):

--8<-- "quickstart-install.md"

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources such as Knative services and event sources, without the need to create or modify YAML files directly.

`kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

--8<-- "install-kn.md"
