resource "google_artifact_registry_repository" "app_repo" {
  location      = var.region
  repository_id = "sales-app"
  format        = "DOCKER"
  description   = "Docker images for Sales Platform"
}
