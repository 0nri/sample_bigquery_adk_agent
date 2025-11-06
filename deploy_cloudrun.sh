#!/bin/bash

# Sample BigQuery ADK Agent Cloud Run Deployment Script

set -e

# --- Configuration Hierarchy ---
# 1. Command-line flags (highest priority)
# 2. .env file (for local development)
# 3. System environment variables (for CI/CD)

# --- Script Logic ---

# Function to load .env file if it exists
load_env() {
  if [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
  fi
}

# Load .env file first
load_env

# Set default values from environment variables (or hardcoded if not set)
PROJECT_ID_DEFAULT="${GOOGLE_CLOUD_PROJECT}"
REGION_DEFAULT="${CLOUD_RUN_REGION:-us-central1}"
SERVICE_NAME_DEFAULT="${CLOUD_RUN_SERVICE_NAME:-sample-bq-agent}"
SERVICE_ACCOUNT_DEFAULT="${CLOUD_RUN_SERVICE_ACCOUNT}"
MEMORY_DEFAULT="${CLOUD_RUN_MEMORY:-1Gi}"
CPU_DEFAULT="${CLOUD_RUN_CPU:-1}"
TIMEOUT_DEFAULT="${CLOUD_RUN_TIMEOUT:-300}"
MAX_INSTANCES_DEFAULT="${CLOUD_RUN_MAX_INSTANCES:-2}"

# Parse command line arguments, which will override env vars
while [[ $# -gt 0 ]]; do
  case $1 in
    --project)
      PROJECT_ID_DEFAULT="$2"
      shift 2
      ;;
    --region)
      REGION_DEFAULT="$2"
      shift 2
      ;;
    --service-name)
      SERVICE_NAME_DEFAULT="$2"
      shift 2
      ;;
    --service-account)
      SERVICE_ACCOUNT_DEFAULT="$2"
      shift 2
      ;;
    --memory)
      MEMORY_DEFAULT="$2"
      shift 2
      ;;
    --cpu)
      CPU_DEFAULT="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT_DEFAULT="$2"
      shift 2
      ;;
    --max-instances)
      MAX_INSTANCES_DEFAULT="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --project PROJECT_ID       Your Google Cloud Project ID."
      echo "  --region REGION            The Cloud Run region (default: ${REGION_DEFAULT})."
      echo "  --service-name NAME        The name for the Cloud Run service (default: ${SERVICE_NAME_DEFAULT})."
      echo "  --service-account EMAIL    The service account email for Cloud Run (default: ${SERVICE_ACCOUNT_DEFAULT})."
      echo "  --memory MEMORY            The memory allocation for the service (default: ${MEMORY_DEFAULT})."
      echo "  --cpu CPU                  The CPU allocation for the service (default: ${CPU_DEFAULT})."
      echo "  --timeout TIMEOUT          The request timeout in seconds (default: ${TIMEOUT_DEFAULT})."
      echo "  --max-instances INSTANCES  The maximum number of container instances (default: ${MAX_INSTANCES_DEFAULT})."
      echo "  --help                     Show this help message."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Final variable assignment
PROJECT_ID="$PROJECT_ID_DEFAULT"
REGION="$REGION_DEFAULT"
SERVICE_NAME="$SERVICE_NAME_DEFAULT"
SERVICE_ACCOUNT="$SERVICE_ACCOUNT_DEFAULT"
MEMORY="$MEMORY_DEFAULT"
CPU="$CPU_DEFAULT"
TIMEOUT="$TIMEOUT_DEFAULT"
MAX_INSTANCES="$MAX_INSTANCES_DEFAULT"

# Validate required parameters
if [ -z "$PROJECT_ID" ]; then
  echo "Error: Project ID is not set. Please provide it via --project flag, .env file, or GOOGLE_CLOUD_PROJECT environment variable."
  exit 1
fi

echo "=== Sample BigQuery ADK Agent Deployment ==="
echo "Project ID:      $PROJECT_ID"
echo "Region:          $REGION"
echo "Service Name:    $SERVICE_NAME"
echo "Service Account: $SERVICE_ACCOUNT"
echo "Memory:          $MEMORY"
echo "CPU:             $CPU"
echo "Timeout:         $TIMEOUT"
echo "Max Instances:   $MAX_INSTANCES"
echo

# Check for required files
for f in main.py requirements.txt Dockerfile .env; do
  if [ ! -f "$f" ]; then
    echo "Error: Required file '$f' not found in the current directory."
    exit 1
  fi
done

# Set the project for gcloud
echo "Setting Google Cloud project to '$PROJECT_ID'..."
gcloud config set project "$PROJECT_ID"

# Enable necessary services
echo "Enabling required Google Cloud services (run, artifactregistry, cloudbuild)..."
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com

# Build environment variables string from the .env file, and add GOOGLE_GENAI_USE_VERTEXAI
echo "Loading environment variables from .env file..."
ENV_VARS="GOOGLE_GENAI_USE_VERTEXAI=true"
while IFS='=' read -r key value || [ -n "$key" ]; do
  # Skip comments and empty lines
  if [[ ! "$key" =~ ^#.*$ ]] && [[ -n "$key" ]]; then
    # Remove potential quotes and whitespace
    value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' | xargs)
    if [ -n "$ENV_VARS" ]; then
      ENV_VARS="$ENV_VARS,"
    fi
    ENV_VARS="$ENV_VARS$key=$value"
  fi
done < .env

echo "Deploying to Cloud Run..."

# Build gcloud deploy command with service account if provided
DEPLOY_CMD="gcloud run deploy \"$SERVICE_NAME\" \
  --source . \
  --region \"$REGION\" \
  --project \"$PROJECT_ID\" \
  --allow-unauthenticated \
  --set-env-vars=\"$ENV_VARS\" \
  --memory=\"$MEMORY\" \
  --cpu=\"$CPU\" \
  --timeout=\"$TIMEOUT\" \
  --max-instances=\"$MAX_INSTANCES\""

# Add service account if specified
if [ -n "$SERVICE_ACCOUNT" ]; then
  DEPLOY_CMD="$DEPLOY_CMD --service-account=\"$SERVICE_ACCOUNT\""
fi

# Execute the deployment
eval $DEPLOY_CMD

echo
echo "=== Deployment Complete ==="
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --platform managed --region "$REGION" --format 'value(status.url)' 2>/dev/null || echo "Unable to retrieve service URL.")
echo "Service URL: $SERVICE_URL"
echo "ADK Web Interface is available at the service URL."
echo
