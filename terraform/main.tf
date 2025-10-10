locals {
  startup_script     = file("${path.module}/../scripts/start/catsoop-server.sh")
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = "${var.resource_prefix}-vpc"
  auto_create_subnetworks = true
  depends_on              = [google_project_service.compute]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [var.ssh_source_cidr]
}

resource "google_compute_instance" "vm" {
  name         = "${var.resource_prefix}-server"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["http-server", "https-server", "ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30  # GB
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
    access_config {} # ephemeral IP (free)
  }

  metadata_startup_script = local.startup_script

  shielded_instance_config {
    enable_integrity_monitoring = true  # detect compromised images
    enable_secure_boot          = true  # boot only trusted images
    enable_vtpm                 = true  # virtual TPM for disk encryption
  }

  scheduling {
    preemptible       = false  # keeps the instance running
    automatic_restart = true  # restarts VM if terminated without manual action
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/logging.write"]
  }
}
