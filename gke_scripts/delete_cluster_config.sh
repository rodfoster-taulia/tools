###################################################################
# Script Owner: Rod Foster
# Description: Script REMOVES a cluster from a Fleet and removes
# policy controller and disables security posture
###################################################################

#!/bin/bash

helpFunc()
{
   echo ""
   echo "Usage: $0 -c CLUSTER_NAME -r REGION"
   echo -e "\t-c CLUSTER_NAME is required to specify which cluster to remove from the fleet"
   echo -e "\t-r REGION is required to specify the region of the fleet service's membership"
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

# Ask for permissions and begin script if all parameters are correct
echo "*** This script requires your permission to proceed ***"
echo "You are attemping to REMOVE the \"$CLUSTER_NAME\" cluster from the Fleet service in \"$REGION\"." 
read -p "Would you like to continue? (yes/no): " response
if [[ $response == "yes" ]]; then
  echo "Proceeding with the script..."
else
  echo "Script aborted. No action taken."
  exit 1
fi

# Remove Security Posture
echo "Removing Security Posture from cluster: $CLUSTER_NAME"
gcloud container clusters update $CLUSTER_NAME \
    --region=$REGION \
    --security-posture=disabled

# Remove all constraint template - Parking this command until bundles
# echo "Cleaning up templates and bundles from cluster: $CLUSTER_NAME"
# gcloud alpha container fleet policycontroller content templates disable \
#     --memberships=$CLUSTER_NAME


# Remove Policy Controller
echo "Removing Policy Controller on \"$CLUSTER_NAME\"..."
gcloud alpha container fleet policycontroller disable \
  --memberships=$CLUSTER_NAME

# Remove Cluster from the fleet
echo "Removing \"$CLUSTER_NAME\" from the Fleet"
gcloud container clusters update $CLUSTER_NAME --clear-fleet-project --region $REGION

# Show clusters in Fleet
echo ""
echo "Clusters currently configured in the fleet"
echo ""
gcloud container fleet memberships list
