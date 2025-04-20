#!/bin/bash

clear

echo "Starting Execution"

# Step 1: Getting Project ID & User ID
echo "Getting Project ID & User ID"
echo
get_value() {
  read -p "Please enter PROJECT_ID: " PROJECT_ID
  echo
  read -p "Please enter TWIN_USER: " TWIN_USER

  export PROJECT_ID="$PROJECT_ID"
  export TWIN_USER="$TWIN_USER"
}

# Call the function
get_value
echo

# Step 2: Create Authorized View in Data Publisher Dataset
echo "Creating Authorized View in Data Publisher Dataset"
bq mk \
--use_legacy_sql=false \
--view "SELECT * FROM \`${PROJECT_ID}.demo_dataset.authorized_table\` WHERE state_code = 'NY' LIMIT 1000" \
${DEVSHELL_PROJECT_ID}:data_publisher_dataset.authorized_view

# Step 3: Show Dataset Info
echo "Showing Dataset Info for data_publisher_dataset"
bq show --format=prettyjson $DEVSHELL_PROJECT_ID:data_publisher_dataset > temp_dataset.json

# Step 4: Add View Access to Dataset
echo "Adding View Access to Dataset"
jq ".access += [{
  \"view\": {
    \"datasetId\": \"data_publisher_dataset\",
    \"projectId\": \"${DEVSHELL_PROJECT_ID}\",
    \"tableId\": \"authorized_view\"
  }
}]" temp_dataset.json > updated_dataset.json

# Step 5: Update Dataset Permissions
echo "Updating Dataset Permissions"
bq update --source=updated_dataset.json $DEVSHELL_PROJECT_ID:data_publisher_dataset

# Step 6: Create IAM Policy File
echo "Creating IAM Policy File for authorized_view"
cat <<EOF > policy.json
{
  "bindings": [
    {
      "members": [
        "user:${TWIN_USER}"
      ],
      "role": "roles/bigquery.dataViewer"
    }
  ]
}
EOF

# Step 7: Set IAM Policy on the View
echo "Setting IAM Policy on authorized_view"
bq set-iam-policy ${DEVSHELL_PROJECT_ID}:data_publisher_dataset.authorized_view policy.json

# Step 8: Prompt to Login as Data Twin
echo
echo "Now, Login with Customer (Data Twin) Username"
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
    echo
    echo "${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo

cd

remove_files() {
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
