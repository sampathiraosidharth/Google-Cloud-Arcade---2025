#!/bin/bash

# Set Region and Zone from project metadata
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Get Project ID
PROJECT_ID=$(gcloud config get-value project)

# Check if REGION and ZONE are set properly
if [ -z "$REGION" ] || [ -z "$ZONE" ]; then
  echo "Region or Zone could not be fetched from project metadata. Please check your gcloud configuration."
  exit 1
fi

# Enable Cloud services
gcloud services enable run.googleapis.com
if [ $? -ne 0 ]; then
  echo "Failed to enable Cloud Run API."
  exit 1
fi

gcloud services enable cloudfunctions.googleapis.com
if [ $? -ne 0 ]; then
  echo "Failed to enable Cloud Functions API."
  exit 1
fi

# Download the Go sample code
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
if [ $? -ne 0 ]; then
  echo "Failed to download the Go samples."
  exit 1
fi

# Unzip the downloaded file
if ! command -v unzip &> /dev/null; then
  echo "Unzip command not found. Please install unzip and try again."
  exit 1
fi

unzip main.zip
if [ $? -ne 0 ]; then
  echo "Failed to unzip the downloaded file."
  exit 1
fi

# Navigate to the functions directory
cd golang-samples-main/functions/codelabs/gopher || { echo "Directory not found."; exit 1; }

# Deploy the functions
gcloud functions deploy HelloWorld --gen2 --runtime go121 --trigger-http --region "$REGION" --quiet
if [ $? -ne 0 ]; then
  echo "Failed to deploy HelloWorld function."
  exit 1
fi

gcloud functions deploy Gopher --gen2 --runtime go121 --trigger-http --region "$REGION" --quiet
if [ $? -ne 0 ]; then
  echo "Failed to deploy Gopher function."
  exit 1
fi

echo "Functions deployed successfully."
