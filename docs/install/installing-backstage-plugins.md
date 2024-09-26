# Installing Knative Backstage Plugins

Knative community is planning to provide a set of Backstage plugins for Knative and their respective backends.
Currently there is one plugin available, the Event Mesh plugin.

## Event Mesh plugin

The Event Mesh plugin is a Backstage plugin that allows you to view and manage Knative Eventing resources.

The Backstage plugin talks to a special backend that runs in the Kubernetes cluster and communicates with the Kubernetes
API server.

A demo setup for this plugin is available at <https://github.com/aliok/knative-backstage-demo>.

The plugin has 2 distributions: static and dynamic. In this document, we will focus on the static distribution.
For the dynamic distribution, please see the 
[Dynamic Plugin README file](https://github.com/knative-extensions/backstage-plugins/blob/main/backstage/plugins/knative-event-mesh-backend/README-dynamic.md)
in the plugin repository.

### Installation

The plugin needs to be installed in the Backstage instance and the backend it talks to needs to be installed in the 
Kubernetes cluster.

#### Plugin backend controller installation

```shell
VERSION="latest" # or a specific version like knative-v1.15.0
kubectl apply -f https://github.com/knative-extensions/backstage-plugins/releases/${VERSION}/download/eventmesh.yaml
```

This will install the backend controller in the Kubernetes cluster. The backend's responsibility is to talk to 
the Kubernetes API server and provide the necessary information to the plugin.

#### The Backstage plugin installation

In your Backstage directory, run the following command to install the plugin:

```bash
VERSION="latest" # or a specific version like 1.15.0 from https://www.npmjs.com/package/@knative-extensions/plugin-knative-event-mesh-backend
yarn workspace backend add @knative-extensions/plugin-knative-event-mesh-backend@${VERSION}
```

Backstage has a legacy backend system that is being replaced with a new system. If you are using the legacy backend
system, you can follow the instructions below to install the plugin.

To learn more about the new and the legacy backend systems, see the
[Backstage documentation](https://backstage.io/docs/backend-system/building-backends/migrating/).

!!! info
    We are aware there is a `Backend` term used in both the Kubernetes controller and the Backstage backend system. 
    Backstage backend system is different from the Kubernetes controller we've installed before.
    The controller is a Kubernetes controller that runs in the Kubernetes cluster and talks to the Kubernetes API server.
    Backstage backend system is a framework to run backend plugins that talk to data providers, such as the Kubernetes controller mentioned above.

#### Enabling the plugin on the new Backstage backend system

To install on the new backend system, add the following into the `packages/backend/index.ts` file:

```ts
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// Other plugins/modules

backend.add(import('@knative-extensions/plugin-knative-event-mesh-backend/alpha'));
```

!!! warning
    If you have made any changes to the schedule in the `app-config.yaml` file, then restart to apply the changes.

#### Enabling the plugin on the legacy Backstage backend system

Configure the scheduler for the entity provider and enable the processor. Add the following code
to `packages/backend/src/plugins/catalog.ts` file:

```ts
import {CatalogClient} from "@backstage/catalog-client";
import {
    KnativeEventMeshProcessor,
    KnativeEventMeshProvider
} from '@knative-extensions/plugin-knative-event-mesh-backend';

export default async function createPlugin(
    env:PluginEnvironment,
):Promise<Router> {
    const builder = await CatalogBuilder.create(env);

    /* ... other processors and/or providers ... */

    // ADD THESE
    builder.addEntityProvider(
        KnativeEventMeshProvider.fromConfig(env.config, {
            logger: env.logger,
            scheduler: env.scheduler,
        }),
    );
    const catalogApi = new CatalogClient({
        discoveryApi: env.discovery,
    });
    const knativeEventMeshProcessor = new KnativeEventMeshProcessor(catalogApi, env.logger);
    builder.addProcessor(knativeEventMeshProcessor);

    /* ... other processors and/or providers ... */

    const {processingEngine, router} = await builder.build();
    await processingEngine.start();
    return router;
}
```

### Configuration

!!! info
    **NOTE**: The backend needs to be accessible from the Backstage instance. If you are running the backend without
    exposing it, you can use `kubectl port-forward` to forward the port of the backend service to your local machine
    for testing purposes.
    ```bash
    kubectl port-forward -n knative-eventing svc/eventmesh-backend 8080:8080
    ```

The plugin needs to be configured to talk to the backend. It can be configured in the `app-config.yaml` file of the
Backstage instance and allows configuration of one or multiple providers.

Use a `knativeEventMesh` marker to start configuring the `app-config.yaml` file of Backstage:

```yaml
catalog:
  providers:
    knativeEventMesh:
      dev:
        token: '${KNATIVE_EVENT_MESH_TOKEN}'     # SA token to authenticate to the backend
        baseUrl: '${KNATIVE_EVENT_MESH_BACKEND}' # URL of the backend installed in the cluster
        schedule: # optional; same options as in TaskScheduleDefinition
          # supports cron, ISO duration, "human duration" as used in code
          frequency: { minutes: 1 }
          # supports ISO duration, "human duration" as used in code
          timeout: { minutes: 1 }
```

You can either manually change the placeholders in the `app-config.yaml` file or use environment variables to set the
values. The environment variables can be set as following before starting the Backstage instance:

```bash
export KNATIVE_EVENT_MESH_TOKEN=<your-token>
export KNATIVE_EVENT_MESH_BACKEND=<backend-url>
```

The value of `KNATIVE_EVENT_MESH_BACKEND` should be the URL of the backend service. If you are running the backend
service in the same cluster as the Backstage instance, you can use the service name as the URL such as
`http://eventmesh-backend.knative-eventing.svc.cluster.local`.
If the Backstage instance is not running in the same cluster, you can use the external URL of the backend service.
Or, if you are running the backend without exposing it for testing purposes, you can use `kubectl port-forward` as 
mentioned above.

The value of `KNATIVE_EVENT_MESH_TOKEN` should be a service account token that has the necessary permissions to list
the Knative Eventing resources in the cluster. The backend will use this token to authenticate to the Kubernetes API
server. This is required for security reasons as otherwise (if the backend is running with a SA token directly) the
backend would have full access to the cluster will be returning all resources to anyone who can access the backend.

The token will require the following permissions to work properly:

- `get`, `list` and `watch` permissions for `eventing.knative.dev/brokers`, `eventing.knative.dev/eventtypes` and
  `eventing.knative.dev/triggers` resources
- `get` permission for all resources to fetch subscribers for triggers

You can create a ClusterRole with the necessary permissions and bind it to the service account token.

An example configuration is as follows:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-eventmesh-backend-service-account
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: my-eventmesh-backend-cluster-role
rules:
  # permissions for eventtypes, brokers and triggers
  - apiGroups:
      - "eventing.knative.dev"
    resources:
      - brokers
      - eventtypes
      - triggers
    verbs:
      - get
      - list
      - watch
  # permissions to get subscribers for triggers
  # as subscribers can be any resource, we need to give access to all resources
  # we fetch subscribers one by one, we only need `get` verb
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: my-eventmesh-backend-cluster-role-binding
subjects:
  - kind: ServiceAccount
    name: my-eventmesh-backend-service-account
    namespace: default
roleRef:
  kind: ClusterRole
  name: my-eventmesh-backend-cluster-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Secret
metadata:
  name: my-eventmesh-backend-secret
  namespace: default
  annotations:
    kubernetes.io/service-account.name: my-eventmesh-backend-service-account
type: kubernetes.io/service-account-token
```

To get the token, you can run the following command:

```bash
kubectl get secret my-eventmesh-backend-secret -o jsonpath='{.data.token}' | base64 --decode
```

Run a quick check to see if the token works with the Kubernetes API server:

```bash
export KUBE_API_SERVER_URL=$(kubectl config view --minify --output jsonpath="{.clusters[*].cluster.server}") # e.g. "https://192.168.2.151:16443"
export KUBE_SA_TOKEN=$(kubectl get secret my-eventmesh-backend-secret -o jsonpath='{.data.token}' | base64 --decode)
curl -k -H "Authorization: Bearer $KUBE_SA_TOKEN" -X GET "${KUBE_API_SERVER_URL}/apis/eventing.knative.dev/v1/namespaces/default/brokers"
# Should see the brokers, or nothing if there are no brokers
# But, should not see an error
```

Run a second quick check to see if the token works with the Backstage backend:

```bash
export KNATIVE_EVENT_MESH_BACKEND=http://localhost:8080 # or the URL of the backend
export KUBE_SA_TOKEN=$(kubectl get secret my-eventmesh-backend-secret -o jsonpath='{.data.token}' | base64 --decode)
curl -k -H "Authorization: Bearer $KUBE_SA_TOKEN" -X GET "${KNATIVE_EVENT_MESH_BACKEND}"
# Should see the response from the backend such as
# {
#   "brokers" : [...],
#   "eventTypes" : [...]
#}
```

If these quick checks work, you can use the token in the `app-config.yaml` file as the value
of `KNATIVE_EVENT_MESH_TOKEN`.

### Troubleshooting

When you start your Backstage application, you can see some log lines as follows:

```text
[1] 2024-01-04T09:38:08.707Z knative-event-mesh-backend info Found 1 knative event mesh provider configs with ids: dev type=plugin
```

### Usage

See the [plugin documentation](../../eventing/event-registry/eventmesh-backstage-plugin/) for more information about using the plugin.
