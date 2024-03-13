#!/bin/bash
finding_list=(
        "BIGQUERY_TABLE_CMEK_DISABLED"
        "BUCKET_CMEK_DISABLED"
        "CLOUD_ASSET_API_DISABLED"
        "DATAPROC_CMEK_DISABLED"
        "DATASET_CMEK_DISABLED"
        "DISK_CMEK_DISABLED"
        "DISK_CSEK_DISABLED"
        "NODEPOOL_BOOT_CMEK_DISABLED"
        "PUBSUB_CMEK_DISABLED"
        "SQL_CMEK_DISABLED"
        "SQL_NO_ROOT_PASSWORD"
        "SQL_WEAK_ROOT_PASSWORD"
        "VPC_FLOW_LOGS_SETTINGS_NOT_RECOMMENDED"
)


        
    for finding in "${finding_list[@]}"; do
        # occurrence_count=$(
        gcloud alpha scc settings services modules enable \
            --organization=574868413159 \
            --service=SECURITY_HEALTH_ANALYTICS \
            --module="$finding"
        # echo "$occurrence_count"
    done


# Enabled ALL DETECTORS SCC
# https://cloud.google.com/security-command-center/docs/how-to-use-security-health-analytics#enable_and_disable_detectors