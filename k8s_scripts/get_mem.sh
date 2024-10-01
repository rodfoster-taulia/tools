#!/bin/bash

# Get the list of nodes
NODES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep mysql)

# Loop through each node
for NODE in $NODES; do
    echo "Memory usage for node: $NODE"

    # Get memory usage for the node
    MEMORY_USAGE=$(kubectl top node $NODE | awk 'NR>1 {print $2}')

    #MEMORY_USAGE=$(kubectl top node $NODE)
    echo "Memory Usage: $MEMORY_USAGE"
    echo "------------------------"
done