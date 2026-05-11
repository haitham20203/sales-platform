resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_password_value" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "SalesApp@2024!"
}
