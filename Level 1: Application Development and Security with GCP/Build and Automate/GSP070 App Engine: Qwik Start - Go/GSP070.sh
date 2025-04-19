#!/bin/bash

YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"

gcloud services enable appengine.googleapis.com

sleep 10

gcloud config set compute/region $REGION
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

git clone https://github.com/GoogleCloudPlatform/golang-samples.git

cd golang-samples/appengine/go11x/helloworld

sudo apt-get install google-cloud-sdk-app-engine-go

gcloud app deploy

echo "${RED}${BOLD}Congratulations${RESET} ${WHITE}${BOLD}for${RESET} ${GREEN}${BOLD}Completing the Lab !!!${RESET}"
