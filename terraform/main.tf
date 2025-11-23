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
    ports    = ["80", "443", "3000", "8080"]
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
  target_tags   = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_backend" {
  name    = "wandoor-allow-backend"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["30080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_openvpn" {
  name    = "wandoor-allow-openvpn"
  network = "default"
  allow {
    protocol = "udp"
    ports    = ["1194"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-master"]
}

resource "google_compute_firewall" "allow_node_exporter" {
  name    = "wandoor-allow-node-exporter"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["node-exporter"]
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

resource "google_compute_firewall" "allow_ingress_nodeport" {
  name    = "wandoor-allow-ingress-nodeport"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["31661", "31004"] # nginx ingress NodePort
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["wandoor-master", "wandoor-worker"]
}

# ==================== #
# STATIC IPs
# ==================== #

resource "google_compute_address" "master_ip" {
  name   = "wandoor-master-ip"
  region = var.region
}

resource "google_compute_address" "wandoor_lb_ip" {
  name   = "wandoor-k3s-loadbalancer-ip"
  region = var.region
}

# ==================== #
# LOAD BALANCER CONFIG (REGIONAL)
# ==================== #

resource "google_compute_instance_group" "wandoor_group" {
  name      = "wandoor-k3s-group"
  zone      = var.zone
  instances = [
    google_compute_instance.wandoor-master.self_link,
    google_compute_instance.wandoor-worker-1.self_link
  ]

  named_port {
    name = "http"
    port = 31661
  }
}

resource "google_compute_region_health_check" "wandoor_healthcheck" {
  name   = "wandoor-k3s-healthcheck"
  region = var.region

  tcp_health_check {
    port = 31661
  }
}

resource "google_compute_region_backend_service" "wandoor_backend" {
  name        = "wandoor-k3s-backend"
  region      = var.region
  protocol    = "TCP"
  timeout_sec = 15
  load_balancing_scheme = "EXTERNAL"

  health_checks = [google_compute_region_health_check.wandoor_healthcheck.self_link]

  backend {
    group = google_compute_instance_group.wandoor_group.self_link
  }
}

resource "google_compute_forwarding_rule" "wandoor_forward_rule" {
  name                  = "wandoor-k3s-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.wandoor_lb_ip.address
  backend_service       = google_compute_region_backend_service.wandoor_backend.self_link
  port_range            = "80"
}

# ==================== #
# VMS
# ==================== #
resource "google_compute_instance" "wandoor-master" {
  name         = "wandoor-master"
  machine_type = "e2-standard-4"
  zone         = var.zone
  tags         = ["wandoor-master"]

  allow_stopping_for_update = true


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config { nat_ip = google_compute_address.master_ip.address }
  }

  metadata_startup_script = file("${path.module}/scripts/vm-master-init.sh")

    service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}

resource "google_compute_instance" "wandoor-db" {
  name         = "wandoor-db"
  machine_type = "e2-standard-4"
  zone         = var.zone
  tags         = ["wandoor-db"]

  allow_stopping_for_update = true


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 80
      type  = "pd-standard"
    }
  }

  network_interface {
    network        = "default"
    access_config {}
  }
}

resource "google_compute_instance" "wandoor-worker-1" {
  name         = "wandoor-worker-1"
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["wandoor-worker"]

  allow_stopping_for_update = true


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network        = "default"
    access_config {}
  }
}

resource "google_compute_instance" "wandoor-monitoring" {
  name         = "wandoor-monitoring"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["wandoor-monitoring"]

  allow_stopping_for_update = true


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network        = "default"
    access_config {}
  }
}
