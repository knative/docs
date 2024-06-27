#!/bin/bash

# Prompt the user to start the installation process
echo "🚀 Solution Script: This script will install everything required to run the Bookstore Sample App, and the Bookstore itself."

# Validate that the user is in the correct directory /solution
if [ "${PWD##*/}" != "solution" ]; then
    echo "⚠️ Please run this script in the /solution directory. Exiting..."
    exit
fi
echo "✅ You are in the correct directory: /solution"
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

# Wait until all pods in knative-serving and knative-eventing become ready
echo ""
echo "⏳ Waiting for Knative Serving and Eventing pods to be ready..."
kubectl wait --for=condition=ready pod --all -n knative-serving --timeout=300s
kubectl wait --for=condition=ready pod --all -n knative-eventing --timeout=300s
echo "✅ All Knative pods are ready."

# Detect whether the user has knative function "func" installed
if ! command -v func &> /dev/null
then
    echo ""
    echo "⚠️ Knative CLI 'func' not found. Please install the Knative CLI by following the instructions at https://knative.dev/docs/admin/install/kn-cli/."
    exit
fi

# Detect whether the user has kamel CLI installed
if ! command -v kamel &> /dev/null
then
    echo ""
    echo "⚠️ Kamel CLI not found. Please install the Kamel CLI by following the instructions at https://camel.apache.org/camel-k/latest/installation/installation.html."
    exit
fi

# Prompt for the Docker registry details
echo ""
echo "📝 Please provide the details of your Container registry to install the Camel-K."
read -p "🔑 Enter the registry hostname (e.g., docker.io or quay.io): " REGISTRY_HOST
read -p "🔑 Enter the registry username: " REGISTRY_USER
read -s -p "🔑 Enter the registry password: " REGISTRY_PASSWORD
echo ""
echo "✅ All the required details have been captured and saved locally."

# Set the registry details as environment variables
export REGISTRY_HOST=$REGISTRY_HOST
export REGISTRY_USER=$REGISTRY_USER
export REGISTRY_PASSWORD=$REGISTRY_PASSWORD

# Set the KO_DOCKER_REPO environment variable
export KO_DOCKER_REPO=$REGISTRY_HOST/$REGISTRY_USER

# Install Camel-K
echo ""
echo "📦 Installing Camel-K..."
kamel install --registry $REGISTRY_HOST --organization $REGISTRY_USER --registry-auth-username $REGISTRY_USER --registry-auth-password $REGISTRY_PASSWORD
echo "✅ Camel-K installed successfully."

# Install the Sample Bookstore App
echo ""
echo "📚 Installing the Sample Bookstore App..."
read -p "🛑 Press ENTER to continue..."

# Install the front end first
echo ""
echo "📦 Installing the Sample Bookstore Frontend..."
cd frontend
kubectl apply -f config

# Wait for the frontend to be ready
echo ""
echo "⏳ Waiting for the frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=bookstore-frontend --timeout=300s
echo "✅ Bookstore Frontend installed."


# Prompt the user to check the frontend
echo ""
echo "✅ The frontend is now installed. Please visit http://localhost:3000 to view the bookstore frontend."
echo "⚠️ If you cannot access the frontend, please open a new terminal and run 'kubectl port-forward svc/bookstore-frontend-svc 3000:3000' to forward the port to your localhost."
read -p '🛑 Can you see the front end page? If yes, press ENTER to continue...'

# Install the node-server
echo ""
echo "📦 Installing the Sample Bookstore Backend (node-server)..."
cd ../node-server
kubectl apply -f config

# Wait for the backend to be ready
echo ""
echo "⏳ Waiting for the backend to be ready..."
kubectl wait --for=condition=ready pod -l app=node-server --timeout=300s

echo "✅ Bookstore Backend (node-server) installed."

# Prompt the user to check the backend
echo ""
echo "✅ The node-server is now installed. Please visit http://localhost:8080 to view the bookstore node-server."
echo "⚠️ If you cannot access it, please run 'kubectl port-forward svc/node-server-svc 8080:80' to forward the port to your localhost."
read -p '🛑 Can you see "Hello World!"? If yes, press ENTER to continue...'

# Deploy the ML services
echo ""
echo "📦 Deploying the ML service: bad-word-filter..."
cd ../ML-bad-word-filter
func deploy -b=s2i -v
echo "✅ ML service bad-word-filter deployed."

echo ""
echo "📦 Deploying the ML services: sentiment-analysis..."
cd ../ML-sentiment-analysis
func deploy -b=s2i -v
echo "✅ ML service sentiment-analysis deployed."

# Install the database
echo ""
echo "📦 Installing the database..."
cd ..
kubectl apply -f db-service
echo "✅ Database installed."

# Install the sequence
echo ""
echo "📦 Installing the sequence..."
kubectl apply -f sequence/config
echo "✅ Sequence installed."

# Ask the user to edit the properties file
echo ""
echo "📝 Please edit slack-sink/application.properties to provide the webhook URL for Slack."
read -p "🛑 Press ENTER to continue..."

# Create the secret
echo ""
echo "🔑 Creating the secret for Slack..."
kubectl create secret generic slack-credentials --from-file=slack-sink/application.properties
echo "✅ Slack secret created."

# Install the slack-sink
echo ""
echo "📦 Installing the Slack Sink..."
kubectl apply -f slack-sink/config

# Wait for the slack-sink to be ready
echo ""
echo "⏳ Waiting for the slack-sink to be ready..."
kubectl wait --for=condition=ready pod -l app=pipe-00001 --timeout=300s
echo "✅ Slack Sink installed."

# Ask user to open a new terminal to set the minikube tunnel
echo ""
echo "🌐 If you are using minikube: Please open a new terminal and run 'minikube tunnel' to expose the services to the outside world."
read -p "🛑 Press ENTER to continue..."

echo ""
echo "🎉 The setup is now complete!"
