echo "Installing minikube latest..."
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
echo "Done"

echo "Installing kn cli..."
wget https://github.com/knative/client/releases/download/knative-v1.1.0/kn-linux-amd64 -O kn
chmod +x kn
mv kn /usr/local/bin/
echo "Done"

echo "Waiting for Kubernetes to start. This may take a few moments, please wait..."
useradd -u 1024 -g docker -m docker
sudo -H -u docker bash -c 'minikube start'
minikube start
while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
echo "Kubernetes Started"

echo "Installing quickstart ..."
wget https://github.com/knative-sandbox/kn-plugin-quickstart/releases/download/knative-v1.1.0/kn-quickstart-linux-amd64 -O kn-quickstart
chmod +x kn-quickstart
mv kn-quickstart /usr/local/bin/
echo "Done"

export latest_version=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/knative/serving/tags?per_page=1 | jq -r .[0].name)
echo "Latest knative version is: ${latest_version}"

echo "Installing quickstart ..."
kn quickstart minikube
echo "Done"
