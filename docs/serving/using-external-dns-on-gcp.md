---
title: "Using ExternalDNS on Google Cloud Platform to automate DNS setup"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 70
type: "docs"
---

[ExternalDNS](https://github.com/kubernetes-incubator/external-dns) is a tool
that synchronizes exposed Kubernetes Services and Ingresses with DNS providers.

This doc explains how to set up ExternalDNS within a Knative cluster using
[Google Cloud DNS](https://cloud.google.com/dns/) to automate the process of
publishing the Knative domain.

## Set up environtment variables

Run the following command to configure the environment variables

```shell
export PROJECT_NAME=<your-google-cloud-project-name>

export CUSTOM_DOMAIN=<your-custom-domain-used-in-knative>

export CLUSTER_NAME=<knative-cluster-name>

export CLUSTER_ZONE=<knative-cluster-zone>
```

## Set up Kubernetes Engine cluster with CloudDNS read/write permissions

There are two ways to set up a Kubernetes Engine cluster with CloudDNS
read/write permissions.

### Cluster with Cloud DNS scope

You can create a GKE cluster with Cloud DNS scope by entering the following
command:

```shell
gcloud container clusters create $CLUSTER_NAME \
    --zone=$CLUSTER_ZONE \
    --cluster-version=latest \
    --machine-type=n1-standard-4 \
    --enable-autoscaling --min-nodes=1 --max-nodes=10 \
    --enable-autorepair \
    --scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore,"https://www.googleapis.com/auth/ndev.clouddns.readwrite" \
    --num-nodes=3
```

Note that by using this way, any pod within the cluster will have permissions to
read/write CloudDNS.

### Cluster with Cloud DNS Admin Service Account credential

1. Create a GKE cluster without Cloud DNS scope by entering the following
   command:

```shell
gcloud container clusters create $CLUSTER_NAME \
    --zone=$CLUSTER_ZONE \
    --cluster-version=latest \
    --machine-type=n1-standard-4 \
    --enable-autoscaling --min-nodes=1 --max-nodes=10 \
    --enable-autorepair \
    --scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore \
    --num-nodes=3
```

2. Create a new service account for Cloud DNS admin role.

```shell
# Name of the service account you want to create.
export CLOUD_DNS_SA=cloud-dns-admin

gcloud --project $PROJECT_NAME iam service-accounts \
    create $CLOUD_DNS_SA \
    --display-name "Service Account to support ACME DNS-01 challenge."
```

3. Bind the role `dns.admin` to the newly created service account.

```shell
# Fully-qualified service account name also has project-id information.
export CLOUD_DNS_SA=$CLOUD_DNS_SA@$PROJECT_NAME.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding $PROJECT_NAME \
    --member serviceAccount:$CLOUD_DNS_SA \
    --role roles/dns.admin
```

4. Download the secret key file for your service account.

```shell
gcloud iam service-accounts keys create ~/key.json \
    --iam-account=$CLOUD_DNS_SA
```

5. Upload the service account credential to your cluster. This command uses the
   secret name `cloud-dns-key`, but you can choose a different name.

```shell
kubectl create secret generic cloud-dns-key \
    --from-file=key.json=$HOME/key.json
```

6. Delete the local secret

```shell
rm ~/key.json
```

Now your cluster has the credential of your CloudDNS admin service account. And
it can be used to access your Cloud DNS. You can enforce the access of the
credentail secret within your cluster, so that only the pods that have the
permission to get the credential secret can access your Cloud DNS.

## Set up Knative

1. Follow the [instruction](../install/README.md) to install Knative on your
   cluster.
1. Configure Knative to use your custom domain.

```shell
kubectl edit cm config-domain --namespace knative-serving
```

This command opens your default text editor and allows you to edit the config
map.

```
apiVersion: v1
data:
  example.com: ""
kind: ConfigMap
[...]
```

Edit the file to replace `example.com` with your custom domain (the value of
`$CUSTOM_DOMAIN`) and save your changes. In this example, we use domain
`external-dns-test.my-org.do` for all routes:

```
apiVersion: v1
data:
  external-dns-test.my-org.do: ""
kind: ConfigMap
[...]
```

## Set up ExternalDNS

This guide uses Google Cloud Platform as an example to show how to set up
ExternalDNS. You can find detailed instructions for other cloud providers in the
[ExternalDNS documentation](https://github.com/kubernetes-incubator/external-dns#deploying-to-a-cluster).

### Create a DNS zone for managing DNS records

Skip this step if you already have a zone for managing the DNS records of your
custom domain.

A DNS zone which will contain the managed DNS records needs to be created.

Use the following command to create a DNS zone with
[Google Cloud DNS](https://cloud.google.com/dns/):

```shell
export DNS_ZONE_NAME=<dns-zone-name>

gcloud dns managed-zones create $DNS_ZONE_NAME \
    --dns-name $CUSTOM_DOMAIN \
    --description "Automatically managed zone by kubernetes.io/external-dns"
```

Make a note of the nameservers that were assigned to your new zone.

```shell
gcloud dns record-sets list \
    --zone $DNS_ZONE_NAME \
    --name $CUSTOM_DOMAIN \
    --type NS
```

You should see output similar to the following assuming your custom domain is
`external-dns-test.my-org.do`:

```
NAME                             TYPE  TTL    DATA
external-dns-test.my-org.do.  NS    21600  ns-cloud-e1.googledomains.com.,ns-cloud-e2.googledomains.com.,ns-cloud-e3.googledomains.com.,ns-cloud-e4.googledomains.com.
```

In this case, the DNS nameservers are `ns-cloud-{e1-e4}.googledomains.com`.
Yours could differ slightly, e.g. {a1-a4}, {b1-b4} etc.

If this zone has the parent zone, you need to add NS records of this zone into
the parent zone so that this zone can be found from the parent. Assuming the
parent zone is `my-org-do` and the parent domain is `my-org.do`, and the parent
zone is also hosted at Google Cloud DNS, you can follow these steps to add the
NS records of this zone into the parent zone:

```shell
gcloud dns record-sets transaction start --zone "my-org-do"
gcloud dns record-sets transaction add ns-cloud-e{1..4}.googledomains.com. \
    --name "external-dns-test.my-org.do." --ttl 300 --type NS --zone "my-org-do"
gcloud dns record-sets transaction execute --zone "my-org-do"
```

### Deploy ExternalDNS

Firstly, choose the manifest of ExternalDNS.

Use below manifest if you set up your cluster with
[CloudDNS scope](#cluster-with-cloud-dns-scope).

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
  - apiGroups: ["extensions"]
    resources: ["ingresses"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
  - kind: ServiceAccount
    name: external-dns
    namespace: default
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
        - name: external-dns
          image: registry.opensource.zalan.do/teapot/external-dns:latest
          args:
            - --source=service
            - --domain-filter=$CUSTOM_DOMAIN # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            - --provider=google
            - --google-project=$PROJECT_NAME # Use this to specify a project different from the one external-dns is running inside
            - --policy=sync # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            - --registry=txt
            - --txt-owner-id=my-identifier
```

Or use below manifest if you set up your cluster with
[CloudDNS service account credential](#cluster-with-cloud-dns-admin-service-account-credential).

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["pods,secrets"]
    verbs: ["get", "watch", "list"]
  - apiGroups: ["extensions"]
    resources: ["ingresses"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
  - kind: ServiceAccount
    name: external-dns
    namespace: default
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      volumes:
        - name: google-cloud-key
          secret:
            secretName: cloud-dns-key
      serviceAccountName: external-dns
      containers:
        - name: external-dns
          image: registry.opensource.zalan.do/teapot/external-dns:latest
          volumeMounts:
            - name: google-cloud-key
              mountPath: /var/secrets/google
          env:
            - name: GOOGLE_APPLICATION_CREDENTIALS
              value: /var/secrets/google/key.json
          args:
            - --source=service
            - --domain-filter=$CUSTOM_DOMAIN # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            - --provider=google
            - --google-project=$PROJECT_NAME # Use this to specify a project different from the one external-dns is running inside
            - --policy=sync # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            - --registry=txt
            - --txt-owner-id=my-identifier
```

Then use the following command to apply the manifest you chose to install
ExternalDNS

```shell
cat <<EOF | kubectl apply --filename -
<your-chosen-manifest>
EOF
```

You should see ExternalDNS is installed by running:

```shell
kubectl get deployment external-dns
```

### Configuring Knative Gateway service

In order to publish the Knative Gateway service, the annotation
`external-dns.alpha.kubernetes.io/hostname: '*.$CUSTOM_DOMAIN` needs to be added
into Knative gateway service:

```shell
INGRESSGATEWAY=istio-ingressgateway

kubectl edit svc $INGRESSGATEWAY --namespace istio-system
```

This command opens your default text editor and allows you to add the annotation
to `istio-ingressgateway` service. After you've added your annotation, your
file may look similar to this (assuming your custom domain is
`external-dns-test.my-org.do`):

```
apiVersion: v1
kind: Service
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: '*.external-dns-test.my-org.do'
    ...
```

### Verify ExternalDNS works

After roughly two minutes, check that a corresponding DNS record for your
service was created.

```shell
gcloud dns record-sets list     --zone $DNS_ZONE_NAME     --name "*.$CUSTOM_DOMAIN."
```

You should see output similar to:

```
NAME                            TYPE  TTL  DATA
*.external-dns-test.my-org.do.  A     300  35.231.248.30
*.external-dns-test.my-org.do.  TXT   300  "heritage=external-dns,external-dns/owner=my-identifier,external-dns/resource=service/istio-system/istio-ingressgateway"
```

### Verify domain has been published

You can check if the domain has been published to the Internet be entering the
following command:

```shell
host test.external-dns-test.my-org.do
```

You should see the below result after the domain is published:

```
test.external-dns-test.my-org.do has address 35.231.248.30
```

> Note: The process of publishing the domain to the Internet can take several
> minutes.
