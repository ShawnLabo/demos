/*
  App
    - Cloud Run
*/

resource "google_service_account" "backend" {
  account_id = "backend"
}

resource "google_cloud_run_service" "backend" {
  name     = "backend"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
      service_account_name = google_service_account.backend.email
    }
  }

  depends_on = [google_project_service.run]

  lifecycle {
    ignore_changes = [template]
  }
}

resource "google_project_iam_member" "firestore-backend-user" {
  project = data.google_project.project.id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_cloud_run_service_iam_member" "backend-pubsub-invoker" {
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.backend-invoker.email}"
}

/*
  Pub/Sub
*/

resource "google_service_account" "backend-invoker" {
  account_id = "backend-invoker"
}

resource "google_pubsub_topic" "dog-status" {
  name = "dog-status"
}

resource "google_pubsub_subscription" "backend-invoker" {
  name  = "backend-invoker"
  topic = google_pubsub_topic.dog-status.name

  push_config {
    push_endpoint = google_cloud_run_service.backend.status[0].url

    oidc_token {
      service_account_email = google_service_account.backend-invoker.email
    }
  }
}

/*
  DevOps
    - Source Repositories
    - Cloud Build
    - Artifact Registry
*/

resource "google_sourcerepo_repository" "backend" {
  name = "backend"

  depends_on = [google_project_service.sourcerepo]
}

resource "google_sourcerepo_repository_iam_member" "backend-cloudbuild-reader" {
  repository = google_sourcerepo_repository.backend.name
  role       = "roles/source.reader"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_cloudbuild_trigger" "backend" {
  name     = "backend"
  location = var.region
  filename = "cloudbuild.yaml"

  trigger_template {
    repo_name   = google_sourcerepo_repository.backend.name
    branch_name = "main"
  }

  depends_on = [google_project_service.cloudbuild]
}

resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = "backend"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_artifact_registry_repository_iam_member" "backend-cloudbuild-writer" {
  location   = google_artifact_registry_repository.backend.location
  repository = google_artifact_registry_repository.backend.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_artifact_registry_repository_iam_member" "backend-app-reader" {
  location   = google_artifact_registry_repository.backend.location
  repository = google_artifact_registry_repository.backend.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_cloud_run_service_iam_member" "backend-cloudbuild-developer" {
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role     = "roles/run.developer"
  member   = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_service_account_iam_member" "backend-cloudbuild-serviceAccountUser" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}
