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
  description = "Organization of workspace that created the Kubernetes cluster"
}

variable "vault_token" {
  type        = string
  description = "Vault token to use for authentication"
  sensitive   = true
}

variable "pow_difficulty" {
  type        = number
  description = "Number of leading hexadecimal zeros required for the proof-of-work digest."
  default     = 4

  validation {
    condition     = var.pow_difficulty >= 3 && var.pow_difficulty <= 8
    error_message = "pow_difficulty must be between 3 and 8 leading zeros."
  }
}

variable "pow_nonce" {
  type        = string
  description = "Nonce that solves the proof-of-work challenge exposed by the plan output."
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.pow_nonce)) > 0
    error_message = "Provide a non-empty pow_nonce value that satisfies the challenge."
  }
}