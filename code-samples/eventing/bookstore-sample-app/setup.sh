#!/bin/bash

# Prompt the user to start the installation process
echo "This script will install Knative Serving, Knative Eventing, and set up a Kafka cluster on your Kubernetes cluster."
read -p "Press ENTER to continue or Ctrl+C to abort..."

# Install Knative Serving
echo "Installing Knative Serving..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.13.1/serving-core.yaml
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.13.0/kourier.yaml

# Configure Kourier as the default ingress
kubectl patch configmap/config-network --namespace knative-serving --type merge --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'

echo "Knative Serving installed successfully."

# Install Knative Eventing
echo "Installing Knative Eventing..."
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.13.4/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.13.4/eventing-core.yaml
echo "Knative Eventing installed successfully."

# Prompt for Kafka cluster installation
echo "Please install the Kafka cluster using the script provided in knative-extensions/eventing-kafka-broker."
read -p "Press ENTER after you have installed the Kafka cluster to continue with the setup of Kafka components..."

# Install Kafka Channel and Kafka Broker
echo "Installing Kafka components..."
kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-controller.yaml
kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-channel.yaml
kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-broker.yaml

echo "Kafka components installation completed successfully."
echo "The installation of all components is complete. Your cluster is now set up with Knative Serving, Knative Eventing, and Kafka."

# End of script
