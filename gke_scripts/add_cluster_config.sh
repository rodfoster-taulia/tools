#####################################################################
# Script Owner: Rod Foster
# Description: Script Adds a cluster to the Fleet and configures
# policy controller and enabled security posture in audit mode
#
# ** NOTE ** Script must be run from authenticated cluster and region
######################################################################

#!/bin/bash

helpFunc()
{
   echo ""
   echo "Usage: $0 -c CLUSTER_NAME -r REGION"
   echo -e "\t-c CLUSTER_NAME is required to specify which cluster to add to the fleet"
   echo -e "\t-r REGION is required for membership configuration so that the Fleet service runs in the same region as the cluster"
   exit 1 # Exit script after printing help
}

while getopts "c:r:" opt
do
   case "$opt" in
      c ) CLUSTER_NAME="$OPTARG" ;;
      r ) REGION="$OPTARG" ;;
      ? ) helpFunc ;; # Print help function in case parameter is non-existent
   esac
done

# Print help function in case parameters are empty
if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ]
then
   echo "Some or all of the parameters are empty";
   helpFunc
fi

# Print chosen parameters
# echo "Cluster to configure: $CLUSTER_NAME"
# echo "Fleet service region: $REGION"

# Fleet Status Command
FLEET_STATUS=$(gcloud container clusters describe $CLUSTER_NAME --region=$REGION --format="value(fleet)")

# Check if Cluster is already apart of a Fleet
 
if [ -n "$FLEET_STATUS" ];
then
   echo "The \"$CLUSTER_NAME\" cluster is already a member of a fleet"
   exit 1
else
   echo "The \"$CLUSTER_NAME\" cluster is available for Fleet onboarding"
fi

# Confirmation of configuration clusters
echo "*** This script requires your permission to proceed ***"
echo "You are attemping to configure the \"$CLUSTER_NAME\" cluster with the fleet mgmt service in \"$REGION\"." 
read -p "Would you like to continue? (yes/no): " response
if [[ $response == "yes" ]]; then
  echo "Proceeding with the script..."
else
  echo "Script aborted. No action taken."
  exit 1
fi

# Register Cluster to the fleet
echo ""
echo "Registering $CLUSTER_NAME with the fleet"
gcloud container clusters update $CLUSTER_NAME \
  --enable-fleet \
  --region=$REGION

# Install Policy Controller
echo ""
echo "Installing Policy Controller on the $CLUSTER_NAME cluster..."
gcloud alpha container fleet policycontroller enable \
    --memberships=$CLUSTER_NAME \
    --audit-interval=300

# Small pause to give the namespace and deployment creation time to complete.
echo "Pausing for a few seconds to give the gatekeeper deployment time to create..."
sleep 30
echo "Ok, checking now to see if the Policy Controller deployment is complete..."

# Gatekeeper Deployment Names
DEPLOYMENT1=gatekeeper-audit
DEPLOYMENT2=gatekeeper-controller-manager

# # Function to check if a deployment is available
check_completion() {
    local deployment_name=$1
    while [[ "$(kubectl get deployment $deployment_name -n gatekeeper-system -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')" != "True" ]]; do
        echo "Waiting for $deployment_name to be available..."
        sleep 5
    done
}

check_completion $DEPLOYMENT1
check_completion $DEPLOYMENT2

echo "Both deployments are complete!"

# Show Deployed Pods
echo ""
kubectl get pods -n gatekeeper-system
echo ""


# Configure Security Posture
echo "Configuring Security Posture in \"AUDIT mode\" on $CLUSTER_NAME"
gcloud container clusters update $CLUSTER_NAME \
    --location=$REGION \
    --security-posture=standard

# Show list of servers in fleet
echo ""
echo "Clusters currently configured in the fleet"
echo ""
gcloud container fleet memberships list
