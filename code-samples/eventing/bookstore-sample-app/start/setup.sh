#!/bin/bash

# Prompt the user to start the installation process
echo "Shortcut: This script will install Knative, and install the bookstore's frontend and backend on your cluster"
read -p "Press ENTER to continue or Ctrl+C to abort..."

# Install Knative Serving
echo "Installing Knative Serving..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.14.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.14.0/serving-core.yaml
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.14.0/kourier.yaml

# Configure Kourier as the default ingress
kubectl patch configmap/config-network --namespace knative-serving --type merge --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "Knative Serving installed successfully."

# Install Knative Eventing
echo "Installing Knative Eventing..."
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/eventing-core.yaml
echo "Knative Eventing installed successfully."

# Install Knative imc Broker
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/mt-channel-broker.yaml
echo "Knative in-memory Channel and Broker installed successfully."

# Detect whether the user has knative function "func" installed
if ! command -v func &> /dev/null
then
    echo "Knative CLI 'func' not found. Please install the Knative CLI by following the instructions at https://knative.dev/docs/admin/install/kn-cli/."
    exit
fi

# Wait until all pods in knative-serving and knative-eventing to become ready
kubectl wait --for=condition=ready pod --all -n knative-serving --timeout=300s
kubectl wait --for=condition=ready pod --all -n knative-eventing --timeout=300s

# Install the Sample Bookstore App
echo "Installing the Sample Bookstore Frontend"
read -p "Press ENTER to continue..."

# Install the front end first
cd frontend
kubectl apply -f config

# Wait for the frontend to be ready
echo "Waiting for the frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=bookstore-frontend --timeout=300s

# prmopt the user to ask whether they can visit localhost:80, if not we will need to do port-forwarding
echo "The frontend is now installed. Please visit http://localhost:3000 to view the bookstore frontend."
echo "If you cannot access the frontend, please open a new terminal and run 'kubectl port-forward svc/bookstore-frontend-svc 3000:3000' to forward the port to your localhost."
read -p "Press ENTER to continue..."

# Install the backend
echo "Installing the Sample Bookstore node-server"

# Install the node-server
cd ../node-server
kubectl apply -f config/100-deployment.yaml

# wait for the backend to be ready
echo "Waiting for the backend to be ready..."
kubectl wait --for=condition=ready pod -l app=node-server --timeout=300s

# prmopt the user to ask whether they can visit localhost:8080, if not we will need to do port-forwarding
echo "The node-server is now installed. Please visit http://localhost:8080 to view the bookstore node-server."
echo "If you cannot access it, please run 'kubectl port-forward svc/node-server-svc 8080:80' to forward the port to your localhost."
read -p "Press ENTER to continue..."

# The setup is now complete
echo "The setup is now complete. Please go back to tutorial 1 to continue."
