#!/bin/bash

set -e

# Set region
REGION="us-central1"
gcloud config set compute/region "$REGION"

# Enable Cloud Functions API
echo "🔧 Enabling Cloud Functions API..."
gcloud services enable cloudfunctions.googleapis.com

# Download the Go sample code
echo "📦 Downloading sample code..."
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

# Automatically answer 'yes' to file replacement prompts
yes | unzip -q main.zip
cd golang-samples-main/functions/codelabs/gopher

# Display directory tree (optional)
echo "📁 Project structure:"
# tree  # Commented out to avoid command not found error

# Create HelloWorld Function
echo "🚀 Deploying HelloWorld function..."
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

gcloud functions deploy HelloWorld \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region "$REGION" \
  --allow-unauthenticated

# Create Gopher Function
echo "🎨 Deploying Gopher function..."
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

# Gopher image (download directly)
curl -o gophercolor.png https://raw.githubusercontent.com/GoogleCloudPlatform/golang-samples/main/functions/codelabs/gopher/gophercolor.png

gcloud functions deploy Gopher \
  --gen2 \
  --runtime go121 \
  --trigger-http \
  --region "$REGION" \
  --allow-unauthenticated

# Write and run test
echo "🧪 Running tests..."
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

go mod init gopher
go test -v

echo "✅ Lab completed successfully!"
