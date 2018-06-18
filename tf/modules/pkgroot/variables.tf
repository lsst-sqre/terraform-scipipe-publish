variable "aws_default_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_zone_id" {
  description = "route53 Hosted Zone ID to manage DNS records in."
  default     = "Z3TH0HRSNU67AM"
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
  default     = "lsst.codes"
}

# remove "<env>-" prefix for production
data "template_file" "fqdn" {
  template = "${replace("${var.env_name}-${var.service_name}.${var.domain_name}", "prod-", "")}"
}

variable "k8s_host" {}
variable "k8s_client_certificate" {}
variable "k8s_client_key" {}
variable "k8s_cluster_ca_certificate" {}

variable "k8s_namespace" {
  description = "DNS domain name to use when creating route53 records."
  default     = "pkgroot"
}

variable "pkgroot_storage_size" {
  # E.g.: "200Gi" "1Ti"
  description = "Size of gcloud persistent volume claim"
  default     = "1Ti"
}
