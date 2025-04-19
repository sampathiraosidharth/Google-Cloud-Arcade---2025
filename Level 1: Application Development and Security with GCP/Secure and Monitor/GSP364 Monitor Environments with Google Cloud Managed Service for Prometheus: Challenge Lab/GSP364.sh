#!/bin/bash

# Starting Execution
echo "Starting Execution"

# Set up environment variables
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

# Create Kubernetes cluster
gcloud container clusters create gmp-cluster --num-nodes=3 --zone=$ZONE

# Get cluster credentials
gcloud container clusters get-credentials gmp-cluster --zone=$ZONE

# Create namespace for testing
kubectl create ns gmp-test

# Apply necessary Kubernetes configurations
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/setup.yaml
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/manifests/operator.yaml
kubectl -n gmp-test apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/v0.2.3/examples/example-app.yaml

# Create configuration file
cat > op-config.yaml <<'EOF_END'
apiVersion: monitoring.googleapis.com/v1alpha1
collection:
  filter:
    matchOneOf:
    - '{job="prom-example"}'
    - '{__name__=~"job:.+"}'
kind: OperatorConfig
metadata:
  annotations:
    components.gke.io/layer: addon
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"monitoring.googleapis.com/v1alpha1","kind":"OperatorConfig","metadata":{"annotations":{"components.gke.io/layer":"addon"},"labels":{"addonmanager.kubernetes.io/mode":"Reconcile"},"name":"config","namespace":"gmp-public"}}
  creationTimestamp: "2022-03-14T22:34:23Z"
  generation: 1
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
  name: config
  namespace: gmp-public
  resourceVersion: "2882"
  uid: 4ad23359-efeb-42bb-b689-045bd704f295
EOF_END

# Set up Google Cloud Storage bucket
export PROJECT=$(gcloud config get-value project)
gsutil mb -p $PROJECT gs://$PROJECT

# Upload the configuration file
gsutil cp op-config.yaml gs://$PROJECT

# Set bucket access control to public-read
gsutil -m acl set -R -a public-read gs://$PROJECT

# Completion message
echo "Congratulations For Completing The Lab !!!"
