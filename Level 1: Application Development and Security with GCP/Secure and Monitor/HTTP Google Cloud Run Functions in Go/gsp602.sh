#!/bin/bash
# Script to deploy Go Cloud Functions in GCP with manual staging bucket workaround

# Exit if any command fails
set -e

# Detect zone and region
echo "Detecting zone and region..."
export ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
export REGION=$(gcloud config get-value compute/region 2>/dev/null)

# Set default values if not configured
if [ -z "$ZONE" ]; then
  export ZONE="us-central1-a"
  echo "Zone not detected, using default: $ZONE"
fi

if [ -z "$REGION" ]; then
  export REGION="us-central1"
  echo "Region not detected, using default: $REGION"
fi

# Set compute config
echo "Setting compute configuration..."
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

# Get project ID
export PROJECT_ID=$(gcloud config get-value project)
echo "Using project: $PROJECT_ID"

# Enable necessary services
echo "Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com

# Clean up
echo "Cleaning up previous files..."
rm -rf golang-samples-main main.zip

# Download Go samples
echo "Downloading Go samples..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

# Extract Go samples
echo "Extracting Go samples..."
yes A | unzip -q main.zip

# Create staging bucket manually
BUCKET_NAME="gcf-staging-$PROJECT_ID"
echo "Creating staging bucket: $BUCKET_NAME"
gsutil mb -l $REGION gs://$BUCKET_NAME/

# Navigate to function code directory
cd golang-samples-main/functions/codelabs/gopher
echo "Working directory: $(pwd)"

# Deploy HelloWorld function
echo "Deploying HelloWorld function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated \
  --stage-bucket $BUCKET_NAME

# Fetch and test HelloWorld function
echo "Fetching HelloWorld function URL..."
FUNCTION_URL=$(gcloud functions describe HelloWorld --gen2 --region $REGION --format="value(serviceConfig.uri)")
if [ -n "$FUNCTION_URL" ]; then
  echo "Testing HelloWorld function at $FUNCTION_URL"
  curl -s "$FUNCTION_URL"
  echo ""
else
  echo "Warning: Could not get function URL for HelloWorld"
fi

# Deploy Gopher function
echo "Deploying Gopher function..."
gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated \
  --stage-bucket $BUCKET_NAME

echo "✅ Deployment completed successfully!"
echo "🚀 Functions deployed: HelloWorld and Gopher"
