#!/bin/bash

helpFunc()
{
   echo ""
   echo "Usage: $0 -p PROJECT_ID"
   echo -e "\t-c CLUSTER_NAME is required to specify which cluster"
   echo -e "\t-n POD_NAME is required"
   echo -e "\t-n NAMESPACE_NAME is required"
   echo -e "\t-p PROJECT_ID is required to specify which Project the report should be exported from"
   exit 1 # Exit script after printing help
}

while getopts "c:n:p:s:" opt
do
   case "$opt" in
      p ) PROJECT_ID="$OPTARG" ;;
      c ) CLUSTER_NAME="$OPTARG" ;;
      n ) POD_NAME="$OPTARG" ;;
      s ) NAMESPACE_NAME="$OPTARG" ;;
      ? ) helpFunc ;; # Print help function in case parameter is non-existent
   esac
done

# Print help function in case parameters are empty
if [ -z "$CLUSTER_NAME" ] || [ -z "$PROJECT_ID" ]|| [ -z "$POD_NAME" ]|| [ -z "$NAMESPACE_NAME" ]
then
   echo "Some or all of the parameters are empty";
   helpFunc
fi

# Set Namespace
#NAMESPACE_NAME=$($CLUSTER_NAME)

# Set the date format
current_date=$(date +"%Y-%m-%d")
k getist
gcloud scc findings list \
  --filter="severity='HIGH' \
  OR severity='CRITICAL' \
  Ak get poND resource.project_id=$PROJECT_ID \
  AND resource.type='k8s_cluster' \
  AND resource.labels.cluster_name=$CLUSTER_NAME \
i- 