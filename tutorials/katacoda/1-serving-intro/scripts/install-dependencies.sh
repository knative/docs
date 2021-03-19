echo "Installing kn cli..."
wget https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64 -O kn
chmod +x kn
mv kn /usr/local/bin/
echo "Done"

echo "Waiting for Kubernetes to start. This may take a few moments, please wait..."
while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
echo "Kubernetes Started"

export latest_version=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/knative/serving/tags?per_page=1 | jq -r .[0].name)
echo "Latest knative version is: ${latest_version}"
