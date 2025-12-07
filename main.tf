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
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.4.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.48.0"
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
    host                   = "https://${data.tfe_outputs.cluster.values.host}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = var.cluster_ca_certificate
  }
}

data "kubernetes_service" "vault" {
  metadata {
    name      = helm_release.vault.name
    namespace = data.tfe_outputs.consul.values.namespace
  }
}

provider "vault" {
  address = "http://${data.kubernetes_service.vault.status[0].load_balancer[0].ingress[0].ip}:8200"
  token   = var.vault_token
}
