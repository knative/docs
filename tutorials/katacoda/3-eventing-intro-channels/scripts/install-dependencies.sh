
echo "Starting Kubernetes and installing Knative Serving. This may take a few moments, please wait..."
while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
echo "Kubernetes Started."

export latest_version=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/knative/serving/tags?per_page=1 | jq -r .[0].name)
echo "Latest knative version is: ${latest_version}"

echo "Installing Knative Serving..."
kubectl apply --filename https://github.com/knative/serving/releases/download/${latest_version}/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/${latest_version}/serving-core.yaml
kubectl apply --filename https://github.com/knative/net-contour/releases/download/${latest_version}/contour.yaml
kubectl apply --filename https://github.com/knative/net-contour/releases/download/${latest_version}/net-contour.yaml
kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
echo "Knative Serving Installed."
