#!/bin/bash

helpFunc()
{
   echo ""
   echo "Usage: $0 -c CLUSTER_NAME"
   echo -e "\t-c CLUSTER_NAME is required to specify which cluster to install the bundles"
   exit 1 # Exit script after printing help
}

while getopts "c:" opt
do
   case "$opt" in
      c ) CLUSTER_NAME="$OPTARG" ;;
      ? ) helpFunc ;; # Print help function in case parameter is non-existent
   esac
done

# Print help function in case parameters are empty
if [ -z "$CLUSTER_NAME" ]
then
   echo "Please provide the CLUSTER_NAME parameters";
   helpFunc
fi

BUNDLE="cis-k8s-v1.5.1"

# Enable referential constraints
echo "Enabling referential constraints on $CLUSTER_NAME"
gcloud alpha container fleet policycontroller update \
    --memberships=$CLUSTER_NAME \
    --referential-rules

# Install the Bundle
# Create for loop to install multiple bundles if required with arg
# provide list of available bundels with descriptions
echo "Install the \"$BUNDLE\" bundle on $CLUSTER_NAME"
gcloud container hub policycontroller content bundles set $BUNDLE