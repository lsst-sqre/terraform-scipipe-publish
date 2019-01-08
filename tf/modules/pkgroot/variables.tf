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

variable "service_name" {
  description = "service / unqualifed hostname"
  default     = "eups"
}

variable "domain_name" {
  description = "DNS domain name to use when creating route53 records."
}

variable "k8s_namespace" {
  description = "k8s namespace to manage resources within."
  default     = "pkgroot"
}

variable "pkgroot_storage_size" {
  # E.g.: "200Gi" "1Ti"
  description = "Size of gcloud persistent volume claim"
  default     = "1Ti"
}

variable "proxycert" {}
variable "proxykey" {}
variable "dhparam" {}

locals {
  # remove "<env>-" prefix for production
  dns_prefix = "${replace("${var.env_name}-", "prod-", "")}"

  fqdn = "${local.dns_prefix}${var.service_name}.${var.domain_name}"
}
