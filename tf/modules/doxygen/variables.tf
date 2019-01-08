variable "aws_primary_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_zone_id" {
  description = "route53 Hosted Zone ID to manage DNS records in."
}

variable "env_name" {
  description = "AWS tag name to use on resources."
}

variable "service_name" {
  description = "service / unqualifed hostname"
  default     = "doxygen"
}

variable "domain_name" {
  description = "DNS domain name to use when creating route53 records."
}

locals {
  # remove "<env>-" prefix for production
  dns_prefix = "${replace("${var.env_name}-", "prod-", "")}"

  fqdn = "${local.dns_prefix}${var.service_name}.${var.domain_name}"
}
