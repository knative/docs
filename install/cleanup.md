# Cleaning up

Running a cluster costs money, so you might want to delete the cluster
when you're done if you're not using it. Deleting the cluster will also
remove Knative, Istio, and any apps you've deployed. Follow the instructions
below for the cloud platform where your Kubernetes cluster is deployed:

## Azure Kubernetes Service (AKS)

To delete the cluster, enter the following command:
```bash
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait
```

## Gardener

Use the Gardener dashboard to delete your cluster, or execute the following with
kubectl pointing to your `garden-my-project.yaml` kubeconfig:

```
kubectl --kubeconfig garden-my-project.yaml --namespace garden--my-project annotate shoot my-cluster confirmation.garden.sapcloud.io/deletion=true

kubectl --kubeconfig garden-my-project.yaml --namespace garden--my-project delete shoot my-cluster
```

## Google Kubernetes Engine (GKE)

To delete the cluster, enter the following command:

```bash
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```

## IBM Cloud Kubernetes Service (IKS)

To delete the cluster, enter the following command:

```bash
ibmcloud cs cluster-rm $CLUSTER_NAME
```

## Minikube

To delete the cluster, enter the following command:

```bash
minikube delete
```

## Pivotal Container Service (PKS)

To delete the cluster, follow the documentation at [Delete a Cluster](https://docs.pivotal.io/runtimes/pks/1-1/delete-cluster.html).
