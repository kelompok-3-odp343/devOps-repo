  # ====================
  # OUTPUTS
  # ====================
  output "vm_master_external_ip" {
    description = "VM master External IP"
    value       = google_compute_instance.wandoor-master.network_interface[0].access_config[0].nat_ip
  }

  output "wandoor-db_ip" {
    description = "VM worker 1 (DB) Internal IP"
    value       = google_compute_instance.wandoor-db.network_interface[0].network_ip
  }
  output "vm_worker_1_ip" {
    description = "VM worker 1 (DB) Internal IP"
    value       = google_compute_instance.wandoor-worker-1.network_interface[0].network_ip
  }

  output "vm_worker_2_ip" {
    description = "VM worker 2 (App) Internal IP - No External IP"
    value       = google_compute_instance.wandoor-worker-2.network_interface[0].network_ip
  }

  # output "vm3_external_ip" {
  #   description = "VM3 (Monitoring) External IP"
  #   value       = google_compute_instance.vm3_monitoring.network_interface[0].access_config[0].nat_ip
  # }

  # output "vm3_internal_ip" {
  #   description = "VM3 (Monitoring) Internal IP"
  #   value       = google_compute_instance.vm3_monitoring.network_interface[0].network_ip
  # }

  # output "argocd_url" {
  #   description = "ArgoCD URL"
  #   value       = "https://${google_compute_instance.vm1_app.network_interface[0].access_config[0].nat_ip}:30443"
  # }

  # output "grafana_url" {
  #   description = "Grafana URL"
  #   value       = "http://${google_compute_instance.vm3_monitoring.network_interface[0].access_config[0].nat_ip}:3000"
  # }

  output "frontend_url" {
    description = "Frontend URL"
    value       = "http://${google_compute_instance.wandoor-worker-1.network_interface[0].access_config[0].nat_ip}"
  }

  output "ssh_commands" {
    description = "SSH Commands"
    value = {
      vm1 = "gcloud compute ssh wandoor-app --zone=${var.zone}"
      vm2 = "gcloud compute ssh wandoor-db --zone=${var.zone} --internal-ip"
      vm3 = "gcloud compute ssh wandoor-monitoring --zone=${var.zone}"
    }
  }