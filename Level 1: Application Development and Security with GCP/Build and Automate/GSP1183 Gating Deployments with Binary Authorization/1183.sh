#!/bin/bash

# Define color variables
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

# Check and export the default zone for the project
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# If ZONE is not set, prompt for the zone
if [ -z "$ZONE" ]; then
  echo "${RED}No default zone found. Please set the zone manually.${RESET}"
  exit 1
fi

# Start message
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"

# Enable App Engine service
gcloud services enable appengine.googleapis.com

# Wait for a while to ensure the service is enabled
sleep 10

# Set region and zone for the cloud configuration
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Clone the sample repository
git clone https://github.com/GoogleCloudPlatform/golang-samples.git

# Navigate to the app directory
cd golang-samples/appengine/go11x/helloworld

# Install App Engine Go SDK
sudo apt-get install google-cloud-sdk-app-engine-go

# Deploy the app to Google Cloud
gcloud app deploy

# Completion message
echo "${RED}${BOLD}Congratulations${RESET} ${WHITE}${BOLD}for${RESET} ${GREEN}${BOLD}Completing the Lab !!!${RESET}"
