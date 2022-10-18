# detection log

## Set up

Set your project ID.

```sh
gcloud config set project YOUR-PROJECT-ID
gcloud auth application-default login
```

Set environment variables.

```sh
source .envrc
```

Enable services.

```sh
gcloud services enable \
  cloudbuild.googleapis.com \
  pubsub.googleapis.com \
  run.googleapis.com \
  vision.googleapis.com
```

### Configure Cloud Build

Bind required roles to Cloud Build's service account.

```sh
SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${SERVICE_ACCOUNT}" \
  --role "roles/run.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member "serviceAccount:${SERVICE_ACCOUNT}" \
  --role "roles/storage.admin"
```

### Configure Cloud Storage Bucket

Create storage bucket.

```sh
gsutil mb gs://${PROJECT_ID}-images
```

### Configure Cloud Run

Create a service account for logprocessor service.

```sh
gcloud iam service-accounts create logprocessor
```

Give needed roles to the service account.

```sh
gsutil iam ch \
  "serviceAccount:logprocessor@${PROJECT_ID}.iam.gserviceaccount.com:objectCreator" \
  gs://${PROJECT_ID}-images
```

Deploy logprocessor Cloud Run service.

```sh
./tools/logprocessor.sh
```

### Configure Pub/Sub

Create Pub/Sub topic.

```sh
gcloud pubsub topics create detection-log
```

Create a service account for Pub/Sub subscription.

```sh
gcloud iam service-accounts create logprocessor-invoker

SERVICE_ACCOUNT="logprocessor-invoker@${PROJECT_ID}.iam.gserviceaccount.com"
```

Give the service account permission to invoke logprocessor service.

```sh
gcloud run services add-iam-policy-binding logprocessor \
  --region asia-northeast1 \
  --member "serviceAccount:${SERVICE_ACCOUNT}" \
  --role roles/run.invoker
```

Allow Pub/Sub to create authentication tokens in your project.

```sh
gcloud iam service-accounts add-iam-policy-binding \
  "${SERVICE_ACCOUNT}" \
  --member "serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com" \
  --role roles/iam.serviceAccountTokenCreator
```

Create a Pub/Sub subscription.

```sh
SERVICE_URL=$(gcloud run services describe logprocessor --region asia-northeast1 --format "value(status.address.url)")

gcloud pubsub subscriptions create logprocessor \
  --topic detection-log \
  --push-endpoint "${SERVICE_URL}" \
  --push-auth-service-account "${SERVICE_ACCOUNT}"
```

## Deploy logprocessor

```sh
tools/deploy_logprocessor.sh
```

## Publish detection log

```sh
source .envrc
poetry install
poetry run python detect.py examples/ruby_and_ten.jpg
```
