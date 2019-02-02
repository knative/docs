---
title: "Accessing metrics"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 10
---

You access metrics through the [Grafana](https://grafana.com/) UI. Grafana is
the visualization tool for [Prometheus](https://prometheus.io/).

1. To open Grafana, enter the following command:

```
kubectl port-forward --namespace knative-monitoring $(kubectl get pods --namespace knative-monitoring --selector=app=grafana --output=jsonpath="{.items..metadata.name}") 3000
```

- This starts a local proxy of Grafana on port 3000. For security reasons, the
  Grafana UI is exposed only within the cluster.

2. Navigate to the Grafana UI at [http://localhost:3000](http://localhost:3000).

3. Select the **Home** button on the top of the page to see the list of
   pre-installed dashboards (screenshot below):
   ![Knative Dashboards](../images/grafana1.png)

The following dashboards are pre-installed with Knative Serving:

- **Revision HTTP Requests:** HTTP request count, latency, and size metrics per
  revision and per configuration
- **Nodes:** CPU, memory, network, and disk metrics at node level
- **Pods:** CPU, memory, and network metrics at pod level
- **Deployment:** CPU, memory, and network metrics aggregated at deployment
  level
- **Istio, Mixer and Pilot:** Detailed Istio mesh, Mixer, and Pilot metrics
- **Kubernetes:** Dashboards giving insights into cluster health, deployments,
  and capacity usage

4. Set up an administrator account to modify or add dashboards by signing in
   with username: `admin` and password: `admin`.

- Before you expose the Grafana UI outside the cluster, make sure to change the
  password.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
