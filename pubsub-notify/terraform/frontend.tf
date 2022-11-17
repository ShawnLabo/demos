/*
  Frontend
*/

resource "google_service_account" "frontend" {
  account_id = "frontend"
}

resource "google_cloud_run_service" "frontend" {
  name = "frontend"
  location = var.region

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
      service_account_name = google_service_account.frontend.email
    }
  }

  depends_on = [google_project_service.run]

  lifecycle {
    ignore_changes = [template]
  }
}

resource "google_cloud_run_service_iam_member" "frontend-allUser-invoker" {
  location = google_cloud_run_service.frontend.location
  service  = google_cloud_run_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

/*
  DevOps
    - Source Repositories
    - Cloud Build
    - Artifact Registry
*/

resource "google_sourcerepo_repository" "frontend" {
  name = "frontend"

  depends_on = [google_project_service.sourcerepo]
}

resource "google_sourcerepo_repository_iam_member" "frontend-cloudbuild-reader" {
  repository = google_sourcerepo_repository.frontend.name
  role       = "roles/source.reader"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_cloudbuild_trigger" "frontend" {
  name     = "frontend"
  location = var.region
  filename = "cloudbuild.yaml"

  trigger_template {
    repo_name   = google_sourcerepo_repository.frontend.name
    branch_name = "main"
  }

  depends_on = [google_project_service.cloudbuild]
}

resource "google_artifact_registry_repository" "frontend" {
  location      = var.region
  repository_id = "frontend"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_artifact_registry_repository_iam_member" "frontend-cloudbuild-writer" {
  location   = google_artifact_registry_repository.frontend.location
  repository = google_artifact_registry_repository.frontend.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_artifact_registry_repository_iam_member" "frontend-app-reader" {
  location   = google_artifact_registry_repository.frontend.location
  repository = google_artifact_registry_repository.frontend.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.frontend.email}"
}

resource "google_cloud_run_service_iam_member" "frontend-cloudbuild-developer" {
  location = google_cloud_run_service.frontend.location
  service  = google_cloud_run_service.frontend.name
  role     = "roles/run.developer"
  member   = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}

resource "google_service_account_iam_member" "frontend-cloudbuild-serviceAccountUser" {
  service_account_id = google_service_account.frontend.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [google_project_service.cloudbuild]
}
