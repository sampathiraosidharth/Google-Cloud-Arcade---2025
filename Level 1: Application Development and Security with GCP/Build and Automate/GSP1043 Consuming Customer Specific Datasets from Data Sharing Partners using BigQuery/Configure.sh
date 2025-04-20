#!/bin/bash

echo "Starting Execution"
echo
echo "Getting Project ID"
echo

# Step 3: Prompting for Project ID
get_project_id() {
  read -p "Please enter PROJECT_ID: " PROJECT_ID
  export PROJECT_ID="$PROJECT_ID"
}

# Call the function
get_project_id

echo
echo "Creating View in customer_dataset"

bq mk \
--use_legacy_sql=false \
--view "SELECT cities.zip_code, cities.city, cities.state_code, customers.last_name, customers.first_name
FROM \`${DEVSHELL_PROJECT_ID}.customer_dataset.customer_info\` as customers
JOIN \`${PROJECT_ID}.data_publisher_dataset.authorized_view\` as cities
ON cities.state_code = customers.state" \
${DEVSHELL_PROJECT_ID}:customer_dataset.customer_table

echo

# Function to display a random congratulatory message
random_congrats() {
    MESSAGES=(
        "Congratulations for completing the lab!"
        "Well done! Your hard work has paid off!"
        "Amazing job! Lab completed successfully!"
        "Outstanding! You did great!"
        "Great work! One step closer to mastery!"
        "Fantastic effort! Achievement unlocked!"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo "${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo

# Navigate to home
cd

# Function to remove files with specific prefixes
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
