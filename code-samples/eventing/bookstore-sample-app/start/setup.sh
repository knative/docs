#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Prompt the user to start the installation process
echo "🚀 Shortcut: This script will install Knative, and deploy the bookstore's frontend and backend on your cluster"

read -p "🛑 Press ENTER to continue or Ctrl+C to abort..."

# Install Knative Serving
echo ""
echo "📦 Installing Knative Serving..."
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/latest/download/serving-core.yaml
kubectl apply -f https://github.com/knative/net-kourier/releases/latest/download/kourier.yaml

# Configure Kourier as the default ingress
kubectl patch configmap/config-network --namespace knative-serving --type merge --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
echo "✅ Knative Serving installed successfully."

# Install Knative Eventing
echo ""
echo "📦 Installing Knative Eventing..."
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/eventing-core.yaml
echo "✅ Knative Eventing installed successfully."

# Install Knative IMC Broker
echo ""
echo "📦 Installing Knative In-Memory Channel and Broker..."
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/latest/download/mt-channel-broker.yaml
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
kubectl apply -f "${SCRIPT_DIR}/frontend/config"

# Wait for the frontend to be ready
echo ""
echo "⏳ Waiting for the frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=bookstore-frontend --timeout=300s
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' svc/bookstore-frontend-svc --timeout=300s

FRONTEND_IP=$(kubectl get svc -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' bookstore-frontend-svc)

if [[ -z "$FRONTEND_IP" ]]; then
    echo "Unable to get LoadBalancer IP for bookstore-frontend-svc"
    exit 1
fi

# Prompt the user to check the frontend
echo ""
echo "✅ The frontend is now installed. Please visit http://$FRONTEND_IP to view the bookstore frontend."
read -p '🛑 Can you see the front end page? If yes, press ENTER to continue...'

# Install the backend
echo ""
echo "📚 Installing the Sample Bookstore Backend (node-server)"

# Install the node-server
kubectl apply -f "${SCRIPT_DIR}/node-server/config/100-deployment.yaml"

# Wait for the backend to be ready
echo ""
echo "⏳ Waiting for the backend to be ready..."
kubectl wait --for=condition=ready pod -l app=node-server --timeout=300s
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' svc/node-server-svc --timeout=300s

NODE_SERVER_IP=$(kubectl get svc -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' node-server-svc)

if [[ -z "${NODE_SERVER_IP}" ]]; then
    echo "Unable to get LoadBalancer IP for node-server-svc"
    exit 1
fi

# Prompt the user to check the backend
echo ""
echo "✅ The node-server is now installed. Please visit http://$NODE_SERVER_IP to view the bookstore node-server."
read -p '🛑 Can you see "Hello World!"? If yes, press ENTER to continue...'

# The setup is now complete
echo ""
echo "🎉 The setup is now complete. Please go back to tutorial 1 to continue."
