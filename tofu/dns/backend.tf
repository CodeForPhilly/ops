terraform {
  required_version = "~> 1.12"

  backend "gcs" {
    bucket = "codeforphilly-tfstate"
    prefix = "dns"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.23"
    }
  }
}

provider "google" {
  project = var.project_id
}
