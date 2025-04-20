#!/bin/bash

#----------------------------------------------------start--------------------------------------------------#

echo "Starting Execution"

# Step 1: Get Compute Zone & Region
echo "Fetching Compute Zone & Region..."
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 2: Get IAM Policy and Save to JSON
echo "Retrieving IAM Policy..."
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --format=json > policy.json

# Step 3: Update IAM Policy
echo "Updating IAM Policy..."
jq '{
  "auditConfigs": [
    {
      "service": "cloudresourcemanager.googleapis.com",
      "auditLogConfigs": [
        {
          "logType": "ADMIN_READ"
        }
      ]
    }
  ]
} + .' policy.json > updated_policy.json

# Step 4: Set Updated IAM Policy
echo "Applying Updated IAM Policy..."
gcloud projects set-iam-policy $(gcloud config get-value project) updated_policy.json

# Step 5: Enable Security Center API
echo "Enabling Security Center API..."
gcloud services enable securitycenter.googleapis.com --project=$DEVSHELL_PROJECT_ID

# Step 6: Wait for 20 seconds
echo "Waiting for API to be enabled..."
sleep 20

# Step 7: Add IAM Binding for BigQuery Admin
echo "Granting BigQuery Admin Role..."
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 8: Remove IAM Binding for BigQuery Admin
echo "Revoking BigQuery Admin Role..."
gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 9: Add IAM Binding for IAM Admin
echo "Granting IAM Admin Role..."
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/cloudresourcemanager.projectIamAdmin 2>/dev/null

# Step 10: Create Compute Instance
echo "Creating Compute Instance..."
gcloud compute instances create instance-1 \
--zone=$ZONE \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230912,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced

# Step 11: Create DNS Policy
echo "Creating DNS Policy..."
gcloud dns --project=$DEVSHELL_PROJECT_ID policies create dns-test-policy --description="quickgcplab" --networks="default" --private-alternative-name-servers="" --no-enable-inbound-forwarding --enable-logging

# Step 12: Wait for 30 seconds
echo "Waiting for DNS Policy to take effect..."
sleep 30

# Step 13: SSH into Compute Instance and Execute Commands
echo "Connecting to Compute Instance..."
gcloud compute ssh instance-1 --zone=$ZONE --tunnel-through-iap --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud projects get-iam-policy \$(gcloud config get project) && curl etd-malware-trigger.goog"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "Have you checked your progress for Task 1 & Task 2? (Y/N): "
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "Great! Proceeding to the next steps..."
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "Please check your progress for Task 1 & Task 2 and then press Y to continue."
        else
            echo
            echo "Invalid input. Please enter Y or N."
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 14: Delete Compute Instance
echo "Deleting Compute Instance..."
gcloud compute instances delete instance-1 --zone=$ZONE --quiet

echo

# Function to display a random congratulatory message
function random_congrats() {
    MESSAGES=(
        "Congratulations For Completing The Lab! Keep up the great work!"
        "Well done! Your hard work and effort have paid off!"
        "Amazing job! You’ve successfully completed the lab!"
        "Outstanding! Your dedication has brought you success!"
        "Great work! You’re one step closer to mastering this!"
        "Fantastic effort! You’ve earned this achievement!"
        "Congratulations! Your persistence has paid off brilliantly!"
        "Bravo! You’ve completed the lab with flying colors!"
        "Excellent job! Your commitment is inspiring!"
        "You did it! Keep striving for more successes like this!"
        "Kudos! Your hard work has turned into a great accomplishment!"
        "You’ve smashed it! Completing this lab shows your dedication!"
        "Impressive work! You’re making great strides!"
        "Well done! This is a big step towards mastering the topic!"
        "You nailed it! Every step you took led you to success!"
        "Exceptional work! Keep this momentum going!"
        "Fantastic! You’ve achieved something great today!"
        "Incredible job! Your determination is truly inspiring!"
        "Well deserved! Your effort has truly paid off!"
        "You’ve got this! Every step was a success!"
        "Nice work! Your focus and effort are shining through!"
        "Superb performance! You’re truly making progress!"
        "Top-notch! Your skill and dedication are paying off!"
        "Mission accomplished! This success is a reflection of your hard work!"
        "You crushed it! Keep pushing towards your goals!"
        "You did a great job! Stay motivated and keep learning!"
        "Well executed! You’ve made excellent progress today!"
        "Remarkable! You’re on your way to becoming an expert!"
        "Keep it up! Your persistence is showing impressive results!"
        "This is just the beginning! Your hard work will take you far!"
        "Terrific work! Your efforts are paying off in a big way!"
        "You’ve made it! This achievement is a testament to your effort!"
        "Excellent execution! You’re well on your way to mastering the subject!"
        "Wonderful job! Your hard work has definitely paid off!"
        "You’re amazing! Keep up the awesome work!"
        "What an achievement! Your perseverance is truly admirable!"
        "Incredible effort! This is a huge milestone for you!"
        "Awesome! You’ve done something incredible today!"
        "Great job! Keep up the excellent work and aim higher!"
        "You’ve succeeded! Your dedication is your superpower!"
        "Congratulations! Your hard work has brought great results!"
        "Fantastic work! You’ve taken a huge leap forward today!"
        "You’re on fire! Keep up the great work!"
        "Well deserved! Your efforts have led to success!"
        "Incredible! You’ve achieved something special!"
        "Outstanding performance! You’re truly excelling!"
        "Terrific achievement! Keep building on this success!"
        "Bravo! You’ve completed the lab with excellence!"
        "Superb job! You’ve shown remarkable focus and effort!"
        "Amazing work! You’re making impressive progress!"
        "You nailed it again! Your consistency is paying off!"
        "Incredible dedication! Keep pushing forward!"
        "Excellent work! Your success today is well earned!"
        "You’ve made it! This is a well-deserved victory!"
        "Wonderful job! Your passion and hard work are shining through!"
        "You’ve done it! Keep up the hard work and success will follow!"
        "Great execution! You’re truly mastering this!"
        "Impressive! This is just the beginning of your journey!"
        "You’ve achieved something great today! Keep it up!"
        "You’ve made remarkable progress! This is just the start!"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
