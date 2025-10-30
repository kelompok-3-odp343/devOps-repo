variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "glowing-box-475105-p9"
}
variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-southeast1"
}
variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-southeast1-b"
}
variable "vm_name" {
  description = "VM Instance Name"
  type        = string
  default     = "wandoor-k3s"
}
variable "machine_type" {
  description = "Machine Type"
  type        = string
  default     = "e2-standard-4" # 4 vCPU, 16GB RAM untuk K3s
}
variable "disk_size" {
  description = "Boot Disk Size in GB"
  type        = number
  default     = 50
}
