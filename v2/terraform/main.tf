# ==================== #
# FIREWALL RULES
# ==================== #

resource "google_compute_firewall" "allow_master" {
  name    = "wandoor-allow-master"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "30443"] # SSH, K3s, ArgoCD
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_worker_app" {
  name    = "wandoor-allow-worker-app"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000", "8080"] # frontend + backend
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-worker"]
}

resource "google_compute_firewall" "allow_db_internal" {
  name    = "wandoor-allow-db-internal"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["1521", "5500"]
  }
  source_tags = ["wandoor-master", "wandoor-worker"]
  target_tags = ["wandoor-db"]
}

resource "google_compute_firewall" "allow_lgtm" {
  name    = "wandoor-allow-lgtm"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3000", "3100", "3200","4317", "4318", "4320", "9009", "9090"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-monitoring"]
}
 
resource "google_compute_firewall" "allow_k3s_internal" {
  name    = "wandoor-allow-k3s-internal"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["6443", "10250"]
  }
  allow {
    protocol = "udp"
    ports    = ["8472"]
  }
  source_tags = ["wandoor-master", "wandoor-worker"]
  target_tags = ["wandoor-master", "wandoor-worker"]
}

resource "google_compute_firewall" "allow_frontend" {
  name    = "wandoor-allow-frontend"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["30081"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_backend" {
  name    = "wandoor-allow-backend"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["30080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_openvpn" {
  name    = "wandoor-allow-openvpn"
  network = "default"
  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_node_exporter" {
  name    = "wandoor-allow-node-exporter"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["node-exporter"]
}

resource "google_compute_firewall" "allow_argocd_nodeport" {
  name    = "wandoor-allow-argocd-nodeport"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["31453"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_uptime_kuma" {
  name    = "wandoor-allow-uptime-kuma"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# ==================== #
# STATIC EXTERNAL IPs
# ==================== #

resource "google_compute_address" "master_ip" {
  name = "wandoor-master-ip"
  region = var.region
}

resource "google_compute_address" "db_ip" {
  name = "wandoor-db-ip"
  region = var.region
}

# ==================== #
# VM1: MASTER NODE (ArgoCD)
# ==================== #
resource "google_compute_instance" "wandoor-master" {
  name         = "wandoor-master"
  machine_type = "e2-standard-4" 
  zone         = var.zone
  tags         = ["wandoor-master"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {nat_ip = google_compute_address.master_ip.address} 
  }

  metadata_startup_script = file("${path.module}/scripts/vm-master-init.sh")
 
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

# ==================== #
# VM2: Wandoor DB (Oracle DB)
# ==================== #
resource "google_compute_instance" "wandoor-db" {
  name         = "wandoor-db"
  machine_type = "e2-standard-4"
  zone         = var.zone
  tags         = ["wandoor-db"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 80
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {nat_ip = google_compute_address.db_ip.address}
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

# ==================== #
# VM3: WORKER 1 (FE & BE)
# ==================== #
resource "google_compute_instance" "wandoor-worker-1" {
  name         = "wandoor-worker-1"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["wandoor-worker-1"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

# ==================== #
# VM4: WORKER 2 (Frontend + Backend)
# ==================== #
resource "google_compute_instance" "wandoor-worker-2" {
  name         = "wandoor-worker-2"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["wandoor-worker-2"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    master_ip = google_compute_instance.wandoor-master.network_interface[0].network_ip
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  depends_on = [google_compute_instance.wandoor-master]
}
