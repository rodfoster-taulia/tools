#!/bin/bash -e

# Ask for Pod Name
read -p "Enter the pod name: " POD_NAME

# Get and Show PVC Name
PVC_NAME=$(kubectl describe pod $POD_NAME | grep "ClaimName:" | awk '{print $2}')

if [ -z "$PVC_NAME" ]; then
  echo "No PVC found for pod $POD_NAME. Exiting."
  exit 1
fi

echo "The PVC for this pod is: $PVC_NAME"

# Show Current Size

CURRENT_SIZE=$(kubectl get pvc $PVC_NAME -o=jsonpath='{.spec.resources.requests.storage}')
echo "current size is: $CURRENT_SIZE" 

# Ask for New Disk Size
read -p "Enter the new disk size (in Gi): " NEW_DISK_SIZE


# Patch the PVC to increase disk size
kubectl patch pvc $PVC_NAME \
 --patch '{"spec": {"resources": {"requests": {"storage": "'${NEW_DISK_SIZE}Gi'"}}}}' 

# Verification
echo '================'
echo '= VERIFICATION ='
echo '================'
ACTUAL_SIZE=$(kubectl get pvc $PVC_NAME -o=jsonpath='{.spec.resources.requests.storage}')
echo "Expected new disk size: ${NEW_DISK_SIZE}Gi"
echo "Actual current disk size: $ACTUAL_SIZE"

if [ "$ACTUAL_SIZE" = "${NEW_DISK_SIZE}Gi" ]; then
  echo "PVC resized successfully."
else
  echo "PVC resizing failed."
fi
