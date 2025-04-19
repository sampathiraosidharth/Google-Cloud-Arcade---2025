#!/bin/bash

# Starting Execution
echo "Starting Execution"

# Set up environment variables
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)
export VM_EXT_IP=$(gcloud compute instances describe cls-vm --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Create a new Google Cloud Storage bucket and configure access
gsutil mb -p $DEVSHELL_PROJECT_ID -c STANDARD -l $REGION -b on gs://scc-export-bucket-$DEVSHELL_PROJECT_ID
gsutil uniformbucketlevelaccess set off gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

# Download and upload the findings.jsonl file to the bucket
curl -LO raw.githubusercontent.com/QUICK-GCP-LAB/2-Minutes-Labs-Solutions/refs/heads/main/Mitigate%20Threats%20and%20Vulnerabilities%20with%20Security%20Command%20Center%20Challenge%20Lab/findings.jsonl
gsutil cp findings.jsonl gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

# Provide URLs for the user to interact with
echo "Click here: https://console.cloud.google.com/security/web-scanner/scanConfigs/edit?project=$DEVSHELL_PROJECT_ID"
echo "Copy this: http://$VM_EXT_IP:8080"
echo "NOW FOLLOW VIDEO'S INSTRUCTIONS"
