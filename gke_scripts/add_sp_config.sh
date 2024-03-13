#####################################################################
# Script Owner: Rod Foster
# Description: Script enables security posture configuration auditing
# and vulnerability scanning to clusters.
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