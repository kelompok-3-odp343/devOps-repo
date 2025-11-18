terraform {
  backend "gcs" {
    bucket = "wandoor-terraform-state"
    prefix = "prod/terraform.tfstate"
  }
}
