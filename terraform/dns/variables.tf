variable "aws_access_key" {
  description = "AWS access key id."
}

variable "aws_secret_key" {
  description = "AWS secret access key."
}

variable "env_name" {
  description = "AWS tag name to use on resources."
  default     = "demo"
}

variable "aws_zone_id" {
  description = "route53 Hosted Zone ID to manage DNS records in."
  default     = "Z3TH0HRSNU67AM"
}

variable "domain_name" {
  description = "DNS domain name to use when creating route53 records."
  default     = "lsst.codes"
}
