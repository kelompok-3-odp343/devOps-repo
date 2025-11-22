terraform {
  backend "gcs" {
    bucket = "wandoor-terraform"
    prefix = "prod/state/terraform.tfstate"
  }
}