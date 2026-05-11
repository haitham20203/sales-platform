# The VPC Network — isolated private environment
resource "google_compute_network" "vpc" {
  name                    = "sales-vpc"
  auto_create_subnetworks = false  # We create subnets manually for full control
}

# Private Subnet — where all services live
resource "google_compute_subnetwork" "subnet" {
  name          = "sales-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true  # Allows services to reach GCP APIs without internet
}

# Cloud NAT — allows outbound internet (e.g. downloading packages) without public IPs
resource "google_compute_router" "router" {
  name    = "sales-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "sales-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall — allow only internal traffic between services
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/24"]  # Only traffic from within the subnet
}

# Private Service Access — required for Cloud SQL private IP
resource "google_compute_global_address" "private_ip_range" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
