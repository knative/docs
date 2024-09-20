# Knative Backstage Security

**Author: Ali Ok, Principal Software Engineer @ Red Hat**

## What's new?

In a previous [blog post](../knative-backstage-plugins/), we talked about how to integrate Knative with Backstage. In this blog post, we will talk about how to secure the communication between the Knative Event Mesh plugin and the backend.

Previously, the backend was running with a service account that had full access to the Kubernetes cluster. This was not secure, as the backend could access any resource in the cluster. Also, the backend didn't have any authentication mechanism, so anyone who could access the backend could access the Kubernetes resources, although they were only read-only.

To solve these issues, we have done 2 things:

1. The backend now uses a service account with limited permissions.
2. The backend now requires a token to authenticate (passing it along to the API server), for each request coming from the plugin.

## How it works?

![](/blog/articles/images/knative-backstage-security-01.png)
*Backstage Security*
[//]: # (https://drive.google.com/file/d/1qMu0yd-zGYcveUM_tLigw1yZ_0jksX9i/view?usp=drive_link)

Similar to other Backstage plugins, we wanted the plugin administrator to configure the plugin by setting up the necessary things like the backend URL and the token. It is a similar approach with the [Backstage Kubernetes plugin](https://backstage.io/docs/features/kubernetes/configuration#configuring-kubernetes-clusters), where the user needs to provide the URL and the token.

The token is stored in Backstage configuration and is passed to the backend with each request. The backend uses this token to authenticate to the Kubernetes API server. The token is a service account token that has the necessary permissions to list the Knative Eventing resources in the cluster.

```yaml
...
catalog:
  providers:
    knativeEventMesh:
      dev:
        token: "eyJhb.........NHA"
        baseUrl: "http://eventmesh-backend.knative-eventing.svc:8080"
        schedule: # optional; same options as in TaskScheduleDefinition
          # supports cron, ISO duration, "human duration" as used in code
          frequency: { minutes: 1 }
          # supports ISO duration, "human duration" as used in code
          timeout: { minutes: 1 }
```

How to create the `ServiceAccount`, `ClusterRole`, `ClusterRoleBinding`, `Secret` and the token for that `Secret` is documented in the [plugin's readme file](https://github.com/knative-extensions/backstage-plugins/blob/main/backstage/plugins/knative-event-mesh-backend/README.md).

## Demo and quick start

If you would like to see the plugin in action, you can [install](https://github.com/knative-extensions/backstage-plugins?tab=readme-ov-file#running-the-backstage-plugin){:target="_blank"} the backend in your Kubernetes cluster and the plugin in your Backstage instance.

However, for a quicker look at the plugin, you can check out the [demo video](https://www.youtube.com/watch?v=4h1j1v8KrY0){:target="_blank"}.
The demo video is recorded with the quick start available in Ali Ok's [demo repository](https://github.com/aliok/knative-backstage-demo){:target="_blank"}.

<iframe width="560" height="315" src="https://www.youtube.com/embed/4h1j1v8KrY0?si=tzUmjcrYOfCy6E1H" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Contributions welcome

We are looking for contributors to help us improve the plugin and the backend. If you are interested in contributing, please check out the [README file](https://github.com/knative-extensions/backstage-plugins){:target="_blank"} of the plugins repository. How to start the backend, how to install the plugin, and how to modify the plugin are all documented there.

There are a few issues that are marked as good first issues and we are looking for help with them. If you are interested in contributing, please check out the [good first issues](https://github.com/knative-extensions/backstage-plugins/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22){:target="_blank"}.

## Contact

If you have any questions or feedback, please feel free to reach out to us. You can find us in the [CNCF Slack](https://communityinviter.com/apps/cloud-native/cncf){:target="_blank"} in the [#knative](https://cloud-native.slack.com/archives/C04LGHDR9K7){:target="_blank"} channel.
