#!/bin/bash

# Prompt the user to start the installation process
echo "🚀 Shortcut: This script will install Knative, and deploy the bookstore's frontend and backend on your cluster"

# Validate that the user is in the correct directory /start
if [ "${PWD##*/}" != "start" ]; then
    echo "⚠️ Please run this script in the /start directory. Exiting..."
    exit
fi
echo "✅ You are in the correct directory: /start"
read -p "🛑 Press ENTER to continue or Ctrl+C to abort..."

# Install Knative Serving
echo ""
echo "📦 Installing Knative Serving..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.14.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.14.0/serving-core.yaml
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.14.0/kourier.yaml

# Configure Kourier as the default ingress
kubectl patch configmap/config-network --namespace knative-serving --type merge --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
echo "✅ Knative Serving installed successfully."

# Install Knative Eventing
echo ""
echo "📦 Installing Knative Eventing..."
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/eventing-core.yaml
echo "✅ Knative Eventing installed successfully."

# Install Knative IMC Broker
echo ""
echo "📦 Installing Knative In-Memory Channel and Broker..."
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/mt-channel-broker.yaml
echo "✅ Knative In-Memory Channel and Broker installed successfully."

# Detect whether the user has knative function "func" installed
if ! command -v func &> /dev/null
then
    echo ""
    echo "⚠️ Knative CLI 'func' not found. Please install the Knative CLI by following the instructions at https://knative.dev/docs/functions/install-func"
    exit
fi

# Wait until all pods in knative-serving and knative-eventing become ready
echo ""
echo "⏳ Waiting for Knative Serving and Eventing pods to be ready..."
kubectl wait --for=condition=ready pod --all -n knative-serving --timeout=300s
kubectl wait --for=condition=ready pod --all -n knative-eventing --timeout=300s
echo "✅ All Knative pods are ready."

# Install the Sample Bookstore App
echo ""
echo "📚 Installing the Sample Bookstore Frontend"
read -p "🛑 Press ENTER to continue..."

# Install the front end first
cd frontend
kubectl apply -f config

# Wait for the frontend to be ready
echo ""
echo "⏳ Waiting for the frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=bookstore-frontend --timeout=300s

# Prompt the user to check the frontend
echo ""
echo "✅ The frontend is now installed. Please visit http://localhost:3000 to view the bookstore frontend."
echo "⚠️ If you cannot access the frontend, please open a new terminal and run 'kubectl port-forward svc/bookstore-frontend-svc 3000:3000' to forward the port to your localhost."
read -p '🛑 Can you see the front end page? If yes, press ENTER to continue...'

# Install the backend
echo ""
echo "📚 Installing the Sample Bookstore Backend (node-server)"

# Install the node-server
cd ../node-server
kubectl apply -f config/100-deployment.yaml

# Wait for the backend to be ready
echo ""
echo "⏳ Waiting for the backend to be ready..."
kubectl wait --for=condition=ready pod -l app=node-server --timeout=300s

# Prompt the user to check the backend
echo ""
echo "✅ The node-server is now installed. Please visit http://localhost:8080 to view the bookstore node-server."
echo "⚠️ If you cannot access it, please run 'kubectl port-forward svc/node-server-svc 8080:80' to forward the port to your localhost."
read -p '🛑 Can you see "Hello World!"? If yes, press ENTER to continue...'

# The setup is now complete
echo ""
echo "🎉 The setup is now complete. Please go back to tutorial 1 to continue."