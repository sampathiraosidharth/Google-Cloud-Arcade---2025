#!/bin/bash

# Define color variables
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

# Start message
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"

# Enable App Engine service
gcloud services enable appengine.googleapis.com

# Wait for a while to ensure the service is enabled
sleep 10

# Set region for the cloud configuration
gcloud config set compute/region $REGION

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
