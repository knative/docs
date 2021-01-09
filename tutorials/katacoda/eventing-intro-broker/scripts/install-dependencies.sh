
echo "Starting Kubernetes and installing Knative Serving. This may take a few moments, please wait..."
while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
echo "Kubernetes Started."
echo "Installing Knative Serving..."
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.19.0/serving-core.yaml
kubectl apply --filename https://github.com/knative/net-contour/releases/download/v0.19.0/contour.yaml
kubectl apply --filename https://github.com/knative/net-contour/releases/download/v0.19.0/net-contour.yaml
kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
echo "Knative Serving Installed."
