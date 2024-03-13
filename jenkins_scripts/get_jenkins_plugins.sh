#!/bin/bash

# Define Jenkins URL and credentials
ENV="staging"
JENKINS_URL="https://jenkins.${ENV}.taulia.com"
USERNAME=""
TOKEN=""

# Get the list of installed plugins using Jenkins API
plugins_list=$(curl -sS --user $USERNAME:$TOKEN "$JENKINS_URL/pluginManager/api/json?depth=1" | jq -r '.plugins[] | [.shortName, .version] | @csv')

#Print Output
echo "Plugin Name,Version"
echo "$plugins_list"