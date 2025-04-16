#!/bin/bash

set -e

REGION="us-central1"
gcloud config set compute/region "$REGION"

gcloud services enable cloudfunctions.googleapis.com

# Download the zip file
curl -LO https://github.com/GoogleCloudPlatform/golang-samples/archive/main.zip

# Use 'yes' command to automatically answer 'A' to all prompts
yes A | unzip main.zip

# Navigate to the proper directory
cd golang-samples-main/functions/codelabs/gopher

echo "Project structure:"
tree

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

go mod init gopher
go test -v

echo "Lab completed successfully!"