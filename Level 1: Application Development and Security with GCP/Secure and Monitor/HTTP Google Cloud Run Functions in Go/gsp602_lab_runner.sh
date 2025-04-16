#!/bin/bash
# Simple script to deploy Go Cloud Functions

# Set region based on project info
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "Setting up environment in $REGION..."
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

# Enable required services
echo "Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com

# Download and extract code
echo "Downloading and extracting Go samples..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
# Use yes command to auto-answer unzip prompts with 'A'
yes A | unzip main.zip > /dev/null 2>&1

# Navigate to function directory
cd golang-samples-main/functions/codelabs/gopher
echo "Working directory: $(pwd)"

# Deploy HelloWorld function
echo "Deploying HelloWorld function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated

# Test HelloWorld function
echo "Testing HelloWorld function..."
curl https://$REGION-$GOOGLE_CLOUD_PROJECT.cloudfunctions.net/HelloWorld

# Deploy Gopher function 
echo "Deploying Gopher function..."
gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated

echo "Deployment completed successfully!"
echo "Functions deployed: HelloWorld and Gopher"

# Clean up temporary files
cd
rm -rf golang-samples-main main.zip