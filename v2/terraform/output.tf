  # ====================
  # OUTPUTS
  # ====================

output "vm_ips" {
  value = {
    master = {
      private_ip = google_compute_instance.wandoor-master.network_interface[0].network_ip
      public_ip  = google_compute_instance.wandoor-master.network_interface[0].access_config[0].nat_ip
    }
    db = {
      private_ip = google_compute_instance.wandoor-db.network_interface[0].network_ip
      public_ip  = google_compute_instance.wandoor-db.network_interface[0].access_config[0].nat_ip
    }
    # monitoring = {
    #   private_ip = google_compute_instance.wandoor-monitoring.network_interface[0].network_ip
    #   public_ip  = google_compute_instance.wandoor-monitoring.network_interface[0].access_config[0].nat_ip
    # }
    worker1 = {
      private_ip = google_compute_instance.wandoor-worker-1.network_interface[0].network_ip
      # public_ip  = google_compute_instance.wandoor-worker-1.network_interface[0].access_config[0].nat_ip
    }
    worker2 = {
      private_ip = google_compute_instance.wandoor-worker-2.network_interface[0].network_ip
      # public_ip  = google_compute_instance.wandoor-worker-2.network_interface[0].access_config[0].nat_ip
    }
  }
}


  output "frontend_url" {
    description = "Frontend URL"
    value       = "http://${google_compute_instance.wandoor-master.network_interface[0].access_config[0].nat_ip}"
  }

  output "ssh_commands" {
    description = "SSH Commands"
    value = {
      vm1 = "gcloud compute ssh wandoor-app --zone=${var.zone}"
      vm2 = "gcloud compute ssh wandoor-db --zone=${var.zone} --internal-ip"
      vm3 = "gcloud compute ssh wandoor-monitoring --zone=${var.zone}"
    }
  }