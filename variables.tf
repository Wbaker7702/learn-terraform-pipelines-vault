# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "region" {
  type        = string
  description = "The Google Cloud region."
}

variable "host" {
  type        = string
  description = "The Kubernetes cluster host."
}

variable "cluster_ca_certificate" {
  type        = string
  description = "The Kubernetes cluster CA certificate."
  sensitive   = true
}

variable "release_name" {
  type        = string
  description = "The Helm release name for Consul."
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace for Consul."
}