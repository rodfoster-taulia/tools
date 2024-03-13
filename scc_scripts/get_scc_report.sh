#!/bin/bash

helpFunc()
{
   echo ""
   echo "Usage: $0 -p PROJECT_ID"
   echo -e "\t-p PROJECT_ID is required to specify which Project the report should be exported from"
   exit 1 # Exit script after printing help
}

while getopts "p:" opt
do
   case "$opt" in
      p ) PROJECT_ID="$OPTARG" ;;
      ? ) helpFunc ;; # Print help function in case parameter is non-existent
   esac
done

# Print help function in case parameters are empty
if [ -z "$PROJECT_ID" ]
then
   echo "Please provide the PROJECT_ID parameters";
   helpFunc
fi

# Set the date format
current_date=$(date +"%Y-%m-%d")

# Shorten this up
#Add a findings a list as a variable

# Run Report in CSV Format
echo "Exporting SCC Report from the $PROJECT_ID project"
gcloud scc findings list projects/$PROJECT_ID \
    --filter="state=\"ACTIVE\"" \
    --field-mask="finding.category, \
                finding.severity, \
                finding.kubernetes, \
                finding.event_time, \
                finding.create_time, \
                finding.finding_class, \
                finding.resourceName, \
                finding.state, \
                finding.finding_class, \
                finding.parent_display_name, \
                finding.compliances, \
                finding.description, \
                finding.nextSteps" \
    --format="csv(finding.category, \
                finding.severity, \
                finding.kubernetes, \
                finding.event_time, \
                finding.create_time, \
                finding.finding_class, \
                finding.resourceName, \
                finding.state, \
                finding.finding_class, \
                finding.parent_display_name, \
                finding.compliances, \
                finding.description, \
                finding.nextSteps)" > reports/$PROJECT_ID-scc-report-${current_date}.csv

# Report Complete
echo "Report $PROJECT_ID-scc-report-${current_date} Completed Successfully"
