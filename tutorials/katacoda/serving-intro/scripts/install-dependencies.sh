echo "Installing kn cli..."
wget https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64 -O kn
chmod +x kn
mv kn /usr/local/bin/

echo "Waiting for Kubernetes to start. This may take a few moments, please wait..."
while [ `minikube status &>/dev/null; echo $?` -ne 0 ]; do sleep 1; done
echo "Kubernetes Started"
