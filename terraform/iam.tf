# Service Account for Cloud Run (the Web App)
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
}

# Service Account for Cloud Function (the Pipeline)
resource "google_service_account" "function_sa" {
  account_id   = "function-sa"
  display_name = "Cloud Function Service Account"
}

# Cloud Run SA permissions — needs to access Secret Manager and Pub/Sub
resource "google_project_iam_member" "run_secret" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "run_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud Function SA permissions — needs to write to BigQuery
resource "google_project_iam_member" "function_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "function_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
