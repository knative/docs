#!/bin/bash

# Prompt the user to start the installation process
echo "This script will install Knative Serving, Knative Eventing, and install the sample app bookstore on your cluster"
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

# Install Knative imc broker
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/in-memory-channel.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.14.0/mt-channel-broker.yaml
echo "Knative in-memory channel and broker installed successfully."

# Detect whether the user has knative function "func" installed
if ! command -v func &> /dev/null
then
    echo "Knative CLI 'func' not found. Please install the Knative CLI by following the instructions at https://knative.dev/docs/admin/install/kn-cli/."
    exit
fi

# Detect whether the user has kamel CLI installed
if ! command -v kamel &> /dev/null
then
    echo "Kamel CLI not found. Please install the Kamel CLI by following the instructions at https://camel.apache.org/camel-k/latest/installation/installation.html."
    exit
fi




# Prompt for the Docker registry details
echo "Please provide the details of your Container registry where the sample app images will be pushed."
read -p "Enter the registry hostname (e.g., docker.io or quay.io): " REGISTRY_HOST
read -p "Enter the registry username: " REGISTRY_USER
read -s -p "Enter the registry password: " REGISTRY_PASSWORD
echo "All the required details have been captured and saved locally."

# Set the registry details as environment variables
export REGISTRY_HOST=$REGISTRY_HOST
export REGISTRY_USER=$REGISTRY_USER
export REGISTRY_PASSWORD=$REGISTRY_PASSWORD

# Install the camel-K
kamel install --registry $REGISTRY_HOST--organization $REGISTRY_USER --registry-auth-username $REGISTRY_USER --registry-auth-password $REGISTRY_PASSWORD


# Install the Sample Bookstore App
echo "Installing the Sample Bookstore App..., but please follow the instruction below to tell us your registry details"
read -p "Press ENTER to continue..."

# Install the front end first

TODO: will confirm whether use the pre-built images or build the images locally


## Prompt for Kafka cluster installation
#echo "Please install the Kafka cluster using the script provided in knative-extensions/eventing-kafka-broker."
#read -p "Press ENTER after you have installed the Kafka cluster to continue with the setup of Kafka components..."

# Install Kafka Channel and Kafka Broker
#echo "Installing Kafka components..."
#kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-controller.yaml
#kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-channel.yaml
#kubectl apply -f https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.13.8/eventing-kafka-broker.yaml

#echo "Kafka components installation completed successfully."
echo "The installation of all components is complete. Your cluster is now set up with Knative Serving, Knative Eventing, and Kafka."

# End of script
