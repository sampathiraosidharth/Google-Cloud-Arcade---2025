#!/bin/bash

# Detect and set region and zone for the project
echo "Detecting region and zone..."

REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Fallback to defaults if not found
if [ -z "$REGION" ]; then
  REGION="us-east1"
  echo "Region not found. Using default: $REGION"
fi

if [ -z "$ZONE" ]; then
  ZONE="us-east1-b"
  echo "Zone not found. Using default: $ZONE"
fi

# Set configuration for gcloud
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Get the active project ID
PROJECT_ID=$(gcloud config get-value project)
echo "Active project: $PROJECT_ID"

# Enable required services
echo "Enabling required Cloud APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudfunctions.googleapis.com

# Download and extract the sample Go functions
echo "Downloading sample Go functions..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

echo "Extracting files..."
unzip -q main.zip || yes A | unzip -q main.zip

# Navigate to the appropriate directory
cd golang-samples-main/functions/codelabs/gopher
echo "Current working directory: $(pwd)"

# Deploy HelloWorld Cloud Function
echo "Deploying 'HelloWorld' Cloud Function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated \
  --quiet

# Deploy Gopher Cloud Function
echo "Deploying 'Gopher' Cloud Function..."
gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated \
  --quiet

echo "Deployment completed successfully."
