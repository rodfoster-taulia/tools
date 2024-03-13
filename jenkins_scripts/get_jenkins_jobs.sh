#!/bin/bash

# Jenkins URL and credentials
ENV="staging"
JENKINS_URL="https://jenkins.${ENV}.taulia.com"
USERNAME="rod.foster"
API_TOKEN="114375ddeb021e7602dee2f18604c0dfea"

# API endpoint to get list of jobs
API_ENDPOINT="${JENKINS_URL}/api/json"

# Function to get job details
get_job_details() {
    local job_name="$1"
    local job_url="${JENKINS_URL}/job/${job_name}/lastBuild/api/json"
    
    # Get last build details
    local last_build_info=$(curl -s -u "${USERNAME}:${API_TOKEN}" "${job_url}")
    
    # Extract last success and last failure timestamps
    local last_success=$(echo "${last_build_info}" | jq -r '.timestamp' 2>/dev/null)
    local last_failure=$(echo "${last_build_info}" | jq -r '.lastUnsuccessfulBuild.timestamp' 2>/dev/null)
    
    # Convert timestamps to human-readable format
    last_success_date=$(date -d @"${last_success}" +'%Y-%m-%d %H:%M:%S' 2>/dev/null)
    last_failure_date=$(date -d @"${last_failure}" +'%Y-%m-%d %H:%M:%S' 2>/dev/null)
    
    # Print job details in CSV format
    echo "\"${job_name}\",\"${last_success_date}\",\"${last_failure_date}\""
}

# Print CSV header
echo "Job Name,Last Success,Last Failure"

# Get list of jobs using curl and Jenkins API
jobs=$(curl -s -u "${USERNAME}:${API_TOKEN}" "${API_ENDPOINT}" | jq -r '.jobs[].name')

# Iterate through each job and get its details
for job in ${jobs}; do
    get_job_details "${job}"
done

