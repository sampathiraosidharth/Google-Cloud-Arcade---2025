#!/bin/bash

# Exit on error, but with proper error handling
set -e

REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project)
echo "Using project: $PROJECT_ID"

gcloud config set compute/region "$REGION"

echo "Enabling required services..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable storage.googleapis.com

# Clean up any previous download and extraction
rm -f main.zip
rm -rf golang-samples-main

# Create the bucket manually if it doesn't exist
BUCKET_NAME="gcf-v2-uploads-$PROJECT_ID.$REGION.cloudfunctions.appspot.com"
if ! gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
    echo "Creating bucket $BUCKET_NAME manually..."
    gsutil mb -l $REGION "gs://$BUCKET_NAME" || echo "Bucket creation failed, but may already exist in another form. Continuing..."
fi

# Download fresh and extract
echo "Downloading sample code..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip
yes A | unzip main.zip

# Navigate to the proper directory
cd golang-samples-main/functions/codelabs/gopher

echo "Project structure:"
tree || echo "Tree command not available, continuing anyway..."

cat > hello.go <<EOF
package gopher
import (
    "fmt"
    "net/http"
)
func HelloWorld(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, world.")
}
EOF

echo "Deploying HelloWorld function..."
gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region "$REGION" \
  --allow-unauthenticated || {
    echo "Function deployment failed. Checking if bucket exists..."
    gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null || gsutil mb -l $REGION "gs://$BUCKET_NAME"
    echo "Retrying deployment..."
    gcloud functions deploy HelloWorld \
      --gen2 \
      --runtime go121 \
      --trigger-http \
      --region "$REGION" \
      --allow-unauthenticated
  }

cat > gopher.go <<EOF
package gopher
import (
    "fmt"
    "io"
    "net/http"
    "os"
)
func Gopher(w http.ResponseWriter, r *http.Request) {
    f, err := os.Open("gophercolor.png")
    if err != nil {
        http.Error(w, fmt.Sprintf("Error reading file: %v", err), http.StatusInternalServerError)
        return
    }
    defer f.Close()
    w.Header().Add("Content-Type", "image/png")
    if _, err := io.Copy(w, f); err != nil {
        http.Error(w, fmt.Sprintf("Error writing response: %v", err), http.StatusInternalServerError)
    }
}
EOF

curl -o gophercolor.png https://raw.githubusercontent.com/GoogleCloudPlatform/golang-samples/main/functions/codelabs/gopher/gophercolor.png

echo "Deploying Gopher function..."
gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region "$REGION" \
  --allow-unauthenticated

cat > gopher_test.go <<EOF
package gopher
import (
    "net/http"
    "net/http/httptest"
    "testing"
)
func TestGopher(t *testing.T) {
    rr := httptest.NewRecorder()
    req := httptest.NewRequest("GET", "/", nil)
    Gopher(rr, req)
    if rr.Result().StatusCode != http.StatusOK {
        t.Errorf("Gopher StatusCode = %v, want %v", rr.Result().StatusCode, http.StatusOK)
    }
}
EOF

echo "Running tests..."
go mod init gopher
go test -v

echo "Lab completed successfully!"