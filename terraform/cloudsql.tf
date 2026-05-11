resource "google_sql_database_instance" "main" {
  name             = "sales-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false        # No public IP
      private_network = google_compute_network.vpc.id
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "sales" {
  name     = "salesdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = "salesapp"
  instance = google_sql_database_instance.main.name
  password = "SalesApp@2024!"
}
