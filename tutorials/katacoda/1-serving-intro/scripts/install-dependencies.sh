#echo "Installing minikube latest..."
#wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#sudo install minikube-linux-amd64 /usr/local/bin/minikube
#echo "Done"


#echo "Waiting for Kubernetes to start. This may take a few moments, please wait..."
#curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
#chmod +x ./kind
#mv ./kind /usr/local/bin/kind
##kind create cluster --wait 30s
#echo "Kubernetes Started"

#echo "Installing kubectl ..."
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#echo "Done"

#echo "Installing kn cli..."
#wget https://github.com/knative/client/releases/download/knative-v1.2.0/kn-linux-amd64 -O kn
#chmod +x kn
#mv kn /usr/local/bin/
#echo "Done"

#echo "Waiting for Kubernetes to start. This may take a few moments, please wait..."
#useradd -u 1024 -g docker -m docker
#sudo -H -u docker bash -c 'minikube start'
#while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
#echo "Kubernetes Started"

#echo "Installing quickstart ..."
#wget https://github.com/knative-sandbox/kn-plugin-quickstart/releases/download/knative-v1.2.0/kn-quickstart-linux-amd64 -O kn-quickstart
#chmod +x kn-quickstart
#mv kn-quickstart /usr/local/bin/
#echo "Done"

#echo "Installing yt ..."
#snap install yq
#echo "Done"


#export latest_version=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/knative/serving/tags?per_page=1 | jq -r .[0].name)
#echo "Latest knative version is: ${latest_version}"
#
#echo "Installing quickstart ..."
#kn quickstart kind &
#sleep 3m
#kubectl get deployment -n knative-serving -o yaml | yq 'del(.items[]?.spec.template.spec.containers[]?.resources)' | kubectl apply -f -
#kubectl get deployment -n knative-eventing -o yaml | yq 'del(.items[]?.spec.template.spec.containers[]?.resources)' | kubectl apply -f -
#echo "Done"



launch.sh

kubectl apply -f https://github.com/knative/serving/releases/download/v0.22.3/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v0.22.3/serving-core.yaml

kubectl apply -f https://github.com/knative-sandbox/net-contour/releases/download/v0.22.1/contour.yaml
kubectl apply -f https://github.com/knative-sandbox/net-contour/releases/download/v0.22.1/net-contour.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'

echo "Waiting for external IP "service/envoy" to be assigned..."
until kubectl get service/envoy -n contour-external --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
externalIP=$(kubectl get service/envoy -n contour-external --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP assigned ${externalIP}"

echo "Installing kn cli..."
wget https://github.com/knative/client/releases/download/knative-v1.2.0/kn-linux-amd64 -O kn
chmod +x kn
mv kn /usr/local/bin/
echo "Done"
