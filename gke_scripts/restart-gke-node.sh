#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <node-name> <zone>"
  exit 1
fi
NODE_NAME=$1
ZONE=$2

# Cordon the node
echo "Cordoning the node: $NODE_NAME"
kubectl cordon $NODE_NAME

# Drain the node
echo "Draining the node: $NODE_NAME"
kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data --force

# Get the instance group name
INSTANCE_GROUP=$(gcloud container clusters describe $(kubectl config current-context) --zone $ZONE --format="value(instanceGroupUrls)" | awk -F/ '{print $NF}')

# Get the instance name
INSTANCE_NAME=$(kubectl get node $NODE_NAME -o jsonpath='{.spec.providerID}' | awk -F/ '{print $NF}')

# Restart the node (instance)
echo "Restarting the node: $INSTANCE_NAME in instance group: $INSTANCE_GROUP"
gcloud compute instance-groups managed recreate-instances $INSTANCE_GROUP --instances $INSTANCE_NAME --zone $ZONE

# Wait for the instance to be restarted
echo "Waiting for the node to be ready: $NODE_NAME"
kubectl wait --for=condition=Ready node/$NODE_NAME --timeout=10m
echo "Node $NODE_NAME has been successfully restarted and is ready."