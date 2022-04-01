launch.sh

kubectl apply -f https://github.com/knative/serving/releases/download/v0.22.3/serving-crds.yaml &> /dev/null
kubectl apply -f https://github.com/knative/serving/releases/download/v0.22.3/serving-core.yaml &> /dev/null

kubectl apply -f https://github.com/knative-sandbox/net-contour/releases/download/v0.22.1/contour.yaml &> /dev/null
kubectl apply -f https://github.com/knative-sandbox/net-contour/releases/download/v0.22.1/net-contour.yaml &> /dev/null

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}' &> /dev/null

echo "Waiting for external IP "service/envoy" to be assigned..."
until kubectl get service/envoy -n contour-external --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
externalIP=$(kubectl get service/envoy -n contour-external --output=jsonpath='{.status.loadBalancer.ingress[0].ip}') &> /dev/null
echo "External IP assigned ${externalIP}"

echo "Installing kn cli..."
wget https://github.com/knative/client/releases/download/knative-v1.2.0/kn-linux-amd64 -O kn &> /dev/null
chmod +x kn &> /dev/null
mv kn /usr/local/bin/ &> /dev/null
echo "Done"
