resource "google_app_engine_application" "firestore" {
  location_id = var.firestore_location
  database_type = "CLOUD_FIRESTORE"
}
