#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Defaults
DEFAULT_BUCKET="${PROJECT_ID}-terraform-state"
DEFAULT_REGION="us-west1"

# Parse args
BUCKET_NAME="${1:-$DEFAULT_BUCKET}"
REGION="${2:-$DEFAULT_REGION}"
BACKEND_FILE="../terraform/backend.tf"

# Move to script directory
cd "$(dirname "$0")"

# Step 0: Ensure PROJECT_ID is set
if [ -z "${PROJECT_ID:-}" ]; then
  echo -e "${RED}❌ PROJECT_ID environment variable not set.${RESET}"
  echo "Please export it first:"
  echo "  export PROJECT_ID=<your-project-id>"
  echo
  echo "Then re-run this script."
  exit 1
fi

# Verify project exists and is accessible
if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
  echo -e "${RED}❌ Project '$PROJECT_ID' not found or you lack access.${RESET}"
  echo "Make sure you’ve logged in and set the correct project:"
  echo "  gcloud auth login"
  echo "  gcloud config set project $PROJECT_ID"
  exit 1
fi

echo -e "${GREEN}✅ Using active GCP project:${RESET} ${PROJECT_ID}"

# Step 1: Create or replace backend.tf
if [ -f "$BACKEND_FILE" ]; then
  echo -e "${YELLOW}⚠️  backend.tf already exists — replacing it...${RESET}"
fi

cat > "$BACKEND_FILE" <<EOF
terraform {
  backend "gcs" {
    bucket = "${BUCKET_NAME}"
    prefix = "terraform/state"
  }
}
EOF

echo -e "${GREEN}✅ backend.tf configured for bucket: ${BUCKET_NAME}${RESET}"

# Step 2: Check if bucket exists before creation
if gsutil ls -b "gs://${BUCKET_NAME}/" >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Bucket gs://${BUCKET_NAME}/ already exists. Skipping creation.${RESET}"
else
  echo -e "${GREEN}☁️  Creating bucket gs://${BUCKET_NAME}/ in region ${REGION}...${RESET}"
  gsutil mb -p "${PROJECT_ID}" -l "${REGION}" "gs://${BUCKET_NAME}/"
  echo -e "${GREEN}✅ Bucket created successfully.${RESET}"
fi

# Step 3: Final output
echo
echo -e "${GREEN}Next steps:${RESET}"
echo "  1. terraform init"
echo "  2. terraform apply -var=\"project_id=${PROJECT_ID}\" -var=\"resource_prefix=\$USER\""
echo
echo -e "${GREEN}✅ Setup complete! Script can be re-run safely anytime.${RESET}"
