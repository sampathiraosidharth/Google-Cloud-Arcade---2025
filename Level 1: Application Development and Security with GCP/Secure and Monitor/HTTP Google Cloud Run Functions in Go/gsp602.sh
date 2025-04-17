#!/bin/bash
# Script to deploy Go Cloud Functions with fallback region handling

set -e

echo "Detecting zone and region..."

# Set defaults if not configured
export ZONE=$(gcloud config get-value compute/zone 2>/dev/null)
if [ -z "$ZONE" ]; then
  export ZONE="us-east1-b"
  echo "Zone not detected, using default: $ZONE"
fi

export REGION=$(gcloud config get-value compute/region 2>/dev/null)
if [ -z "$REGION" ]; then
  export REGION="us-east1"
  echo "Region not detected, using default: $REGION"
else
  echo "Testing region permissions for: $REGION"
  export PROJECT_ID=$(gcloud config get-value project)
  TEMP_BUCKET="temp-bucket-$PROJECT_ID-$(date +%s)"
  if ! gsutil mb -l "$REGION" "gs://$TEMP_BUCKET/" 2>/dev/null; then
    echo "Region $REGION is restricted. Falling back to 'us-east1'"
    export REGION="us-east1"
  else
    gsutil rm -r "gs://$TEMP_BUCKET" > /dev/null 2>&1
  fi
fi

echo "Setting compute configuration..."
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

export PROJECT_ID=$(gcloud config get-value project)
echo "Using project: $PROJECT_ID"

echo "Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com

echo "Cleaning up previous files..."
rm -rf golang-samples-main main.zip

echo "Downloading Go samples..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

echo "Extracting Go samples..."
unzip -q main.zip || yes A | unzip -q main.zip

cd golang-samples-main/functions/codelabs/gopher
echo "Working directory: $(pwd)"

echo "Creating staging bucket: gcf-staging-$PROJECT_ID"
if ! gsutil mb -l "$REGION" "gs://gcf-staging-$PROJECT_ID" 2>/dev/null; then
  echo "Staging bucket might already exist or be restricted. Continuing..."
fi

echo "Deploying HelloWorld function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated

echo "Getting HelloWorld function URL..."
FUNCTION_URL=$(gcloud functions describe HelloWorld --gen2 --region $REGION --format="value(serviceConfig.uri)")

if [ -n "$FUNCTION_URL" ]; then
  echo "Testing HelloWorld function at $FUNCTION_URL"
  curl -s "$FUNCTION_URL"
  echo ""
else
  echo "Warning: Could not get function URL for testing"
fi

echo "Deploying Gopher function..."
gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region $REGION \
  --allow-unauthenticated

echo "Deployment completed successfully!"
echo "Functions deployed: HelloWorld and Gopher"
