#!/bin/bash

# Define color variables
YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
WHITE=`tput setaf 7`
BOLD=`tput bold`
RESET=`tput sgr0`

# Starting execution message
echo "${YELLOW}${BOLD}Starting Execution${RESET}"

# Set project and zone details
export PROJECT_ID=$(gcloud info --format="value(config.project)")
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud config get-value compute/region)

# Clone GitHub repo and deploy Firestore
git clone https://github.com/GoogleCloudPlatform/DIY-Tools.git
gcloud firestore import gs://$PROJECT_ID-firestore/prd-back

# Get project number and add IAM policy binding
PROJECT_NUMBER=$(gcloud projects list --filter="PROJECT_ID=$PROJECT_ID" --format="value(PROJECT_NUMBER)")
SERVICE_ACCOUNT_EMAIL="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role "roles/artifactregistry.reader"

# Build and deploy Cloud Run service
cd ~/DIY-Tools/gcp-data-drive
gcloud builds submit --config cloudbuild_run.yaml --project $PROJECT_ID --no-source --substitutions=_GIT_SOURCE_BRANCH="master",_GIT_SOURCE_URL="https://github.com/GoogleCloudPlatform/DIY-Tools"
gcloud beta run services add-iam-policy-binding --region=$REGION --member=allUsers --role=roles/run.invoker gcp-data-drive

# Fetch Cloud Run service URL and make API calls
export CLOUD_RUN_SERVICE_URL=$(gcloud run services --platform managed describe gcp-data-drive --region $REGION --format="value(status.url)")
curl $CLOUD_RUN_SERVICE_URL/fs/$PROJECT_ID/symbols/product/symbol | jq .
curl $CLOUD_RUN_SERVICE_URL/bq/$PROJECT_ID/publicviews/ca_zip_codes | jq .

# Deploy Cloud Function
cat > cloudbuild_gcf.yaml <<'EOF'
steps:
- name: 'gcr.io/cloud-builders/git'
  args: ['clone','--single-branch','--branch','${_GIT_SOURCE_BRANCH}','${_GIT_SOURCE_URL}']
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['functions','deploy','gcp-data-drive','--trigger-http','--runtime','go121','--entry-point','GetJSONData', '--project','$PROJECT_ID','--memory','2048']
  dir: 'DIY-Tools/gcp-data-drive'
EOF
gcloud builds submit --config cloudbuild_gcf.yaml --project $PROJECT_ID --no-source --substitutions=_GIT_SOURCE_BRANCH="master",_GIT_SOURCE_URL="https://github.com/GoogleCloudPlatform/DIY-Tools"
gcloud alpha functions add-iam-policy-binding gcp-data-drive --member=allUsers --role=roles/cloudfunctions.invoker
export CF_TRIGGER_URL=$(gcloud functions describe gcp-data-drive --format="value(httpsTrigger.url)")
curl $CF_TRIGGER_URL/fs/$PROJECT_ID/symbols/product/symbol | jq .
curl $CF_TRIGGER_URL/bq/$PROJECT_ID/publicviews/ca_zip_codes

# Deploy App Engine service
cat > cloudbuild_appengine.yaml <<'EOF'
steps:
- name: 'gcr.io/cloud-builders/git'
  args: ['clone','--single-branch','--branch','${_GIT_SOURCE_BRANCH}','${_GIT_SOURCE_URL}']
- name: 'ubuntu'
  args: ['sed', '-i', 's/runtime: go113/runtime: go121/', 'app.yaml']
  dir: 'DIY-Tools/gcp-data-drive/cmd/webserver'
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['app','deploy','app.yaml','--project','$PROJECT_ID']
  dir: 'DIY-Tools/gcp-data-drive/cmd/webserver'
EOF
gcloud builds submit --config cloudbuild_appengine.yaml --project $PROJECT_ID --no-source --substitutions=_GIT_SOURCE_BRANCH="master",_GIT_SOURCE_URL="https://github.com/GoogleCloudPlatform/DIY-Tools"
export TARGET_URL=https://$(gcloud app describe --format="value(defaultHostname)")

# Fetch App Engine service URL and make API calls
curl $TARGET_URL/fs/$PROJECT_ID/symbols/product/symbol | jq .
curl $TARGET_URL/bq/$PROJECT_ID/publicviews/ca_zip_codes | jq .

# Generate load testing script and run it
cat > loadgen.sh <<EOF
#!/bin/bash
for ((i=1;i<=1000;i++));
do
   curl $TARGET_URL/bq/$PROJECT_ID/publicviews/ca_zip_codes > /dev/null &
done
EOF

chmod +x loadgen.sh
./loadgen.sh

echo "${RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"
