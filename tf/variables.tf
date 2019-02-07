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
  default     = "scipipe-publish"
}

variable "domain_name" {
  description = "DNS domain name to use when creating route53 records."
}

variable "dns_enable" {
  description = "create route53 dns records."
  default     = false
}

variable "google_project" {
  description = "google cloud project ID"
}

variable "google_region" {
  description = "google cloud region"
  default     = "us-central1"
}

variable "google_zone" {
  description = "google cloud region/zone"
  default     = "us-central1-b"
}

variable "tls_crt_path" {
  description = "wildcard tls certificate."
}

variable "tls_key_path" {
  description = "wildcard tls private key."
}

variable "tls_dhparam_path" {
  description = "tls dhparam."
}

variable "redirect_tls_crt_path" {
  description = "sw.lsstcorp.org tls cert."
}

variable "redirect_tls_key_path" {
  description = "sw.lsstcorp.org tls private key."
}

variable "redirect_tls_dhparam_path" {
  description = "redirect tls dhparam."
}

# prod s3 bucket must be > 1TiB
variable "pkgroot_storage_size" {
  description = "Size of gcloud persistent volume claim. E.g.: 200Gi or 1Ti"
  default     = "10Gi"
}

locals {
  # Name of google cloud container cluster to deploy into
  gke_cluster_name = "${var.deploy_name}-${var.env_name}"

  tls_crt     = "${file(var.tls_crt_path)}"
  tls_key     = "${file(var.tls_key_path)}"
  tls_dhparam = "${file(var.tls_dhparam_path)}"

  redirect_tls_crt     = "${file(var.redirect_tls_crt_path)}"
  redirect_tls_key     = "${file(var.redirect_tls_key_path)}"
  redirect_tls_dhparam = "${file(var.redirect_tls_dhparam_path)}"
}
