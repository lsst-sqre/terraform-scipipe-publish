variable "aws_primary_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_zone_id" {
  description = "route53 Hosted Zone ID to manage DNS records in."
}

variable "env_name" {
  description = "Name of deployment environment."
}

variable "deploy_name" {
  description = "Name of deployment."
  default     = "publish-release"
}

variable "domain_name" {
  description = "DNS domain name to use when creating route53 records."
}

variable "google_project" {
  description = "google cloud project ID"
}

variable "tls_crt_path" {
  description = "wildcard tls certificate."
}

variable "tls_key_path" {
  description = "wildcard tls private key."
}

variable "tls_dhparam_path" {
  description = "wildcard tls private key."
}

locals {
  # Name of google cloud container cluster to deploy into
  gke_cluster_name = "${var.deploy_name}-${var.env_name}"

  tls_crt     = "${file(var.tls_crt_path)}"
  tls_key     = "${file(var.tls_key_path)}"
  tls_dhparam = "${file(var.tls_dhparam_path)}"
}
