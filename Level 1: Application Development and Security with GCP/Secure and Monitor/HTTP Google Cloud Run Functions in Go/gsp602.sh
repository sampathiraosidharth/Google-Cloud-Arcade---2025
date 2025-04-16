#!/bin/bash
# Simple script to deploy Go Cloud Functions with error handling

# Exit on command failures but handle them
set -e

# Set region based on project info
echo "Detecting zone and region..."
export ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
export REGION=$(gcloud config get-value compute/region 2>/dev/null)

# If zone or region is not set, use default values
if [ -z "$ZONE" ]; then
  export ZONE="us-central1-a"
  echo "Zone not detected, using default: $ZONE"
fi

if [ -z "$REGION" ]; then
  export REGION="us-central1"
  echo "Region not detected, using default: $REGION"
fi

# Ensure compute configuration
echo "Setting compute configuration..."
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

# Get project ID
export PROJECT_ID=$(gcloud config get-value project)
echo "Using project: $PROJECT_ID"

# Enable required services
echo "Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com

# Clean up any previous files
echo "Cleaning up previous files..."
rm -rf golang-samples-main main.zip

# Download and extract code
echo "Downloading Go samples..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
echo "Extracting Go samples..."
unzip -q main.zip || {
  # If unzip prompts for input, use yes command
  yes A | unzip -q main.zip
}

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

# Get the function URL properly
echo "Getting HelloWorld function URL..."
FUNCTION_URL=$(gcloud functions describe HelloWorld --gen2 --region $REGION --format="value(serviceConfig.uri)")

# Test HelloWorld function
if [ -n "$FUNCTION_URL" ]; then
  echo "Testing HelloWorld function at $FUNCTION_URL"
  curl -s "$FUNCTION_URL"
  echo ""
else
  echo "Warning: Could not get function URL for testing"
fi

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