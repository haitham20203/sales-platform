resource "google_compute_instance" "app_vm" {
  name         = "sales-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    # No access_config = no public IP
  }

  service_account {
    email  = google_service_account.cloud_run_sa.email
    scopes = ["cloud-platform"]
  }

  tags = ["sales-vm"]
}
