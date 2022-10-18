#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

gcloud run deploy logprocessor \
  --project ${PROJECT_ID} \
  --region asia-northeast1 \
  --allow-unauthenticated \
  --service-account logprocessor@${PROJECT_ID}.iam.gserviceaccount.com \
  --source . \
  --args "run,python,logprocessor.py" \
  --set-env-vars "BUCKET_NAME=${BUCKET_NAME}"
