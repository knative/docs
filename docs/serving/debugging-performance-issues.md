---
title: "Investigating performance issues"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 30
---

You deployed your application or function to Knative Serving but its performance
doesn't meet your expectations. Knative Serving provides various dashboards and
tools to help investigate such issues. This document reviews these dashboards
and tools.

## Request metrics

Start your investigation with the "Revision - HTTP Requests" dashboard.

1.  To open this dashboard, open the Grafana UI as described in
    [Accessing Metrics](../accessing-metrics/) and navigate to "Knative
    Serving - Revision HTTP Requests".

1.  Select your configuration and revision from the menu on top left of the
    page. You will see a page like this:

    ![Knative Serving - Revision HTTP Requests](../images/request_dash1.png)

    This dashboard gives visibility into the following for each revision:

    - Request volume
    - Request volume per HTTP response code
    - Response time
    - Response time per HTTP response code
    - Request and response sizes

This dashboard can show traffic volume or latency discrepancies between
different revisions. If, for example, a revision's latency is higher than others
revisions, then focus your investigation on the offending revision through the
rest of this guide.

## Request traces

Next, look into request traces to find out where the time is spent for a single
request.

1.  To access request traces, open the Zipkin UI as described in
    [Accessing Traces](../accessing-traces/).

1.  Select your revision from the "Service Name" dropdown, and then click the
    "Find Traces" button. You'll get a view that looks like this:

    ![Zipkin - Trace Overview](../images/zipkin1.png)

    In this example, you can see that the request spent most of its time in the
    [span](https://github.com/opentracing/specification/blob/master/specification.md#the-opentracing-data-model)
    right before the last, so focus your investigation on that specific span.

1.  Click that span to see a view like the following:

    ![Zipkin - Span Details](../images/zipkin2.png)

    This view shows detailed information about the specific span, such as the
    micro service or external URL that was called. In this example, the call to
    a Grafana URL is taking the most time. Focus your investigation on why that
    URL is taking that long.

## Autoscaler metrics

If request metrics or traces do not show any obvious hot spots, or if they show
that most of the time is spent in your own code, look at autoscaler metrics
next.

1.  To open the autoscaler dashboard, open Grafana UI and select "Knative
    Serving - Autoscaler" dashboard, which looks like this:

    ![Knative Serving - Autoscaler](../images/autoscaler_dash1.png)

This view shows 4 key metrics from the Knative Serving autoscaler:

- Actual pod count: # of pods that are running a given revision
- Desired pod count: # of pods that autoscaler thinks should serve the revision
- Requested pod count: # of pods that the autoscaler requested from Kubernetes
- Panic mode: If 0, the autoscaler is operating in
  [stable mode](https://github.com/knative/serving/blob/master/docs/scaling/DEVELOPMENT.md#stable-mode).
  If 1, the autoscaler is operating in
  [panic mode](https://github.com/knative/serving/blob/master/docs/scaling/DEVELOPMENT.md#panic-mode).

A large gap between the actual pod count and the requested pod count indicates
that the Kubernetes cluster is unable to keep up allocating new resources fast
enough, or that the Kubernetes cluster is out of requested resources.

A large gap between the requested pod count and the desired pod count indicates
that the Knative Serving autoscaler is unable to communicate with the Kubernetes
master to make the request.

In the preceding example, the autoscaler requested 18 pods to optimally serve
the traffic but was only granted 8 pods because the cluster is out of resources.

## CPU and memory usage

You can access total CPU and memory usage of your revision from the "Knative
Serving - Revision CPU and Memory Usage" dashboard, which looks like this:

![Knative Serving - Revision CPU and Memory Usage](../images/cpu_dash1.png)

The first chart shows rate of the CPU usage across all pods serving the
revision. The second chart shows total memory consumed across all pods serving
the revision. Both of these metrics are further divided into per container
usage.

- user-container: This container runs the user code (application, function, or
  container).
- [istio-proxy](https://github.com/istio/proxy): Sidecar container to form an
  [Istio](https://istio.io/docs/concepts/what-is-istio/overview.html) mesh.
- queue-proxy: Knative Serving owned sidecar container to enforce request
  concurrency limits.
- autoscaler: Knative Serving owned sidecar container to provide autoscaling for
  the revision.
- fluentd-proxy: Sidecar container to collect logs from /var/log.

## Profiling

...To be filled...

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
