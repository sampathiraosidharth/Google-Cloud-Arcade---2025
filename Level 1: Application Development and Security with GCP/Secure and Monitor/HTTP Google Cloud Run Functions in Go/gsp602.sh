#!/bin/bash

# Exit immediately if a command fails
set -e

# Fetch the region and zone for the project
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Get project ID
PROJECT_ID=`gcloud config get-value project`

echo "Using Project: $PROJECT_ID"
echo "Region: $REGION, Zone: $ZONE"

# Enable required APIs
echo "Enabling Cloud Functions and Cloud Run APIs..."
gcloud services enable cloudfunctions.googleapis.com run.googleapis.com

# Clean up any previous files (if they exist)
echo "Cleaning up previous files..."
rm -rf golang-samples-main main.zip

# Download the Go samples
echo "Downloading Go samples..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

# Extract the Go samples
echo "Extracting Go samples..."
unzip -q main.zip || { yes A | unzip -q main.zip; }

# Navigate to the Go function directory
cd golang-samples-main/functions/codelabs/gopher
echo "Working directory: $(pwd)"

# Deploy the HelloWorld function (Gen 2, HTTP triggered)
echo "Deploying HelloWorld function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated

# Get the function URL
echo "Getting HelloWorld function URL..."
FUNCTION_URL=$(gcloud functions describe HelloWorld --gen2 --region $REGION --format="value(serviceConfig.uri)")

# Check if the function URL was retrieved successfully
if [ -n "$FUNCTION_URL" ]; then
  echo "Successfully deployed HelloWorld function at $FUNCTION_URL"
  # Test the HelloWorld function
  echo "Testing HelloWorld function..."
  curl -s "$FUNCTION_URL"
  echo ""
else
  echo "Error: Could not retrieve the function URL. Please check for any issues."
  exit 1
fi

# Deploy Gopher function (Gen 2, HTTP triggered)
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
cd ..
rm -rf golang-samples-main main.zip

echo "Clean-up complete."

