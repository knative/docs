---
title: "kn service create"
weight: 04
type: "docs"
---
<!-- TODO: make a reusable snippet-->
To create a Knative service, enter the command:

```shell
kn service create <service-name> --image <image>
```
Where
- `<service-name>` is the name you want to call the service.
- `<image>` is a URL for the image that you want to use for your application.

### Example command

```shell
kn service create helloworld-go --image gcr.io/knative-samples/helloworld-go --env TARGET="Go Sample v1"
```
