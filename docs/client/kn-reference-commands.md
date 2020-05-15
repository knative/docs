---
title: "kn CLI reference"
linkTitle: "kn CLI reference"
weight: 20
type: "docs"
---

The following documentation is a quick reference guide for `kn` CLI commands that can be used with different Knative components.

## Knative Serving kn commands

### Services commands

#### Create a service
```
$ kn service create <SERVICE-NAME> --image <IMAGE> --env <KEY=VALUE>
```
**Example**
```
$ kn service create hello --image gcr.io/knative-samples/helloworld-go --env TARGET=Knative

  Creating service 'hello' in namespace 'default':
    0.271s The Route is still working to reflect the latest desired specification.
    0.580s Configuration "hello" is waiting for a Revision to become ready.
    3.857s ...
    3.861s Ingress has not yet been reconciled.
    4.270s Ready to serve.

  Service 'hello' created with latest revision 'hello-bxshg-1' and URL:
  http://hello-default.apps-crc.testing
```

#### List a service
```
$ kn service list
NAME    URL                                     LATEST          AGE     CONDITIONS   READY   REASON
hello   http://hello.default.apps-crc.testing   hello-gsdks-1   8m35s   3 OK / 3     True
```

#### Update a service

```
$ kn service update hello --env TARGET=Kn
Updating Service 'hello' in namespace 'default':

 10.136s Traffic is not yet migrated to the latest revision.
 10.175s Ingress has not yet been reconciled.
 10.348s Ready to serve.

Service 'hello' updated with latest revision 'hello-dghll-2' and URL:
http://hello.default.apps-crc.testing
```

## Knative Eventing kn commands
