#!/bin/bash -e

# In Scope Pods
server1=mastercard-server
server2=payment-integration-server

# List of endpoints to execute
endpoints=(
    "api.mastercard.com"
    "mtf.api.mastercard.com"
    "api.visa.com"
    "sandbox.api.mastercard.com"
    # Add more endpoints as needed
)

# Function to get list of in-scope pods and their names
echo "Getting list of in-scope pods"
get_pods() {
    kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep -E "$server1|$server2"
}

# Function to call an endpoint from a given pod
# sample call --> k exec intapi-mastercard-server-56667dd4d8-7d4dc -- curl -sSI https://api.visa.com | grep  "HTTP/"
exec_pod_endpoint() {
    local pod=$1
    local endpoint=$2
    # result=$(kubectl exec "$pod" -- /bin/sh -c "$endpoint")
    result=$(kubectl exec "$pod" -- curl -sSI "https://$endpoint")
    if [ $? -eq 0 ]; then
        echo "Called '$endpoint' from $pod:"
        echo "$result"
    else
        echo "Error executing '$endpoint' on $pod"
    fi
}
while true; do
    # Get the list of pods
    pods=$(get_pods)
    if [ -z "$pods" ]; then
        echo "No matching pods found"
        sleep 5
        continue
    fi
    
    # Convert the pods list into an array
    IFS=$'\n' read -rd '' -a pods_array <<< "$pods"
    
    # Randomly select a pod and a endpoint
    selected_pod=${pods_array[$RANDOM % ${#pods_array[@]}]}
    selected_endpoint=${endpoints[$RANDOM % ${#endpoints[@]}]}
    
    # Execute the selected endpoint on the selected pod
    exec_pod_endpoint "$selected_pod" "$selected_endpoint"
    # echo "$exec_pod_endpoint"
    
    # Wait for a random amount of time between 1 to 10 seconds before the next request
    sleep $((RANDOM % 10 + 1))
done
