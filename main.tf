# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.77.0"
    }
  }

  required_version = ">= 1.1.0"
}

# Retrieve GKE cluster information
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${var.host}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = var.cluster_ca_certificate

}

provider "helm" {
  kubernetes {
    host                   = "https://${var.host}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = var.cluster_ca_certificate
  }
}
