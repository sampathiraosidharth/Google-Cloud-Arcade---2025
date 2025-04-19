#!/bin/bash

# Define color variables
BLACK=`tput setaf 0`
CYAN=`tput setaf 6`
BOLD=`tput bold`
RESET=`tput sgr0`

# Get User IDs
read -p "Please enter PUB_USER: " PUB_USER
read -p "Please enter TWIN_USER: " TWIN_USER

# Set environment variables
export PUB_USER="$PUB_USER"
export TWIN_USER="$TWIN_USER"
export PROJECT_ID=$DEVSHELL_PROJECT_ID
export DATASET=demo_dataset
export TABLE=authorized_table

# Step 1: Create BigQuery Table
echo "${BOLD}${CYAN}Creating BigQuery Table...${RESET}"
bq query --location=US --use_legacy_sql=false --destination_table=${PROJECT_ID}:${DATASET}.${TABLE} --replace \
'SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY state_code ORDER BY area_land_meters DESC) AS cities_by_area FROM `bigquery-public-data.geo_us_boundaries.zip_codes`) cities WHERE cities_by_area <= 10 LIMIT 1000;' > /dev/null

# Step 2: Show Dataset Info
echo "${BOLD}${CYAN}Showing Dataset Info${RESET}"
bq show --format=prettyjson ${PROJECT_ID}:${DATASET} > temp_dataset.json

# Step 3: Modify Dataset Access Policy
echo "${BOLD}${CYAN}Modifying Dataset Access Policy${RESET}"
jq ".access += [{\"role\": \"READER\", \"userByEmail\": \"${PUB_USER}\"}, {\"role\": \"READER\", \"userByEmail\": \"${TWIN_USER}\"}]" temp_dataset.json > updated_dataset.json
bq update --source=updated_dataset.json ${PROJECT_ID}:${DATASET}

# Step 4: Create IAM Policy File
echo "${BOLD}${CYAN}Creating IAM Policy File${RESET}"
cat <<EOF > policy.json
{
  "bindings": [{"members": ["user:${PUB_USER}", "user:${TWIN_USER}"], "role": "roles/bigquery.dataViewer"}]
}
EOF

# Step 5: Set IAM Policy on Table
echo "${BOLD}${CYAN}Setting IAM Policy on Table${RESET}"
bq set-iam-policy ${PROJECT_ID}:${DATASET}.${TABLE} policy.json

# Step 6: Prompt to Login with Publisher Account
echo "${BOLD}${CYAN}Login with Data Publisher Username${RESET}"

# Step 7: Display a Random Congratulatory Message
function random_congrats() {
    MESSAGES=("Congratulations!" "Well done!" "Great job!" "Fantastic!" "Amazing work!")
    echo -e "${BOLD}${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}${RESET}"
}

random_congrats

# Step 8: Remove Files Matching Patterns
echo "${BOLD}${CYAN}Removing Files...${RESET}"
for file in *; do
    if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
        rm "$file"
        echo "Removed: $file"
    fi
done
