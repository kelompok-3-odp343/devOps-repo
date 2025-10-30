# Firewall Rules
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k3s-vm"]
}
resource "google_compute_firewall" "allow_k3s" {
  name    = "allow-k3s"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["6443", "443", "80"] # K3s API, HTTPS, HTTP
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k3s-vm"]
}
resource "google_compute_firewall" "allow_argocd" {
  name    = "allow-argocd"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["30080", "30443"] # ArgoCD NodePort
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k3s-vm"]
}
resource "google_compute_firewall" "allow_openvpn" {
  name    = "allow-openvpn"
  network = "default"
  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k3s-vm"]
}
# VM Instance
resource "google_compute_instance" "k3s_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags = ["k3s-vm"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size
      type  = "pd-balanced"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral external IP
    }
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  metadata_startup_script = file("${path.module}/startup-script.sh")
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }
}
# Static External IP (Optional tapi recommended)
resource "google_compute_address" "k3s_ip" {
  name   = "k3s-external-ip"
  region = var.region
}
resource "google_compute_instance" "k3s_vm_with_static_ip" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags = ["k3s-vm"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.k3s_ip.address
    }
  }
  metadata_startup_script = file("${path.module}/startup-script.sh")
  service_account {
    scopes = ["cloud-platform"]
  }
}
