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

variable "dns_overwrite" {
  description = "overwrite pre-existing DNS records."
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

# prod s3 bucket must be > 1TiB
variable "pkgroot_storage_size" {
  description = "Size of gcloud persistent volume claim. E.g.: 200Gi or 1Ti"
  default     = "10Gi"
}

variable "gke_version" {
  description = "gke master/node version"
  default     = "latest"
}

variable "storage_class" {
  description = "Storage class to be used for all persistent disks. For a deployment on k3s use 'local-path'."
  default     = "pd-ssd"
}

data "vault_generic_secret" "grafana_oauth" {
  path = "${local.vault_root}/grafana_oauth"
}

variable "grafana_oauth_client_id" {
  description = "github oauth Client ID for grafana. (default: vault)"
  default     = ""
}

variable "grafana_oauth_client_secret" {
  description = "github oauth Client Secret for grafana. (default: vault)"
  default     = ""
}

variable "grafana_oauth_team_ids" {
  description = "github team id (integer value treated as string)"
  default     = "1936535"
}

resource "random_string" "grafana_admin_pass" {
  length = 20

  keepers = {
    host = "${module.gke.host}"
  }
}

data "vault_generic_secret" "prometheus_oauth" {
  path = "${local.vault_root}/prometheus_oauth"
}

variable "prometheus_oauth_client_id" {
  description = "github oauth client id. (default: vault)"
  default     = ""
}

variable "prometheus_oauth_client_secret" {
  description = "github oauth client secret. (default: vault)"
  default     = ""
}

variable "prometheus_oauth_github_org" {
  description = "limit access to prometheus dashboard to members of this org"
  default     = "lsst-sqre"
}

data "vault_generic_secret" "tls" {
  path = "${local.vault_root}/tls"
}

variable "tls_crt" {
  description = "wildcard tls certificate. (default: vault)"
  default     = ""
}

variable "tls_key" {
  description = "wildcard tls private key. (default: vault)"
  default     = ""
}

locals {
  # Name of google cloud container cluster to deploy into
  gke_cluster_name = "${var.deploy_name}-${var.env_name}"

  # remove "<env>-" prefix for production
  dns_prefix = "${replace("${var.env_name}-", "prod-", "")}"

  prometheus_k8s_namespace    = "monitoring"
  grafana_k8s_namespace       = "grafana"
  nginx_ingress_k8s_namespace = "nginx-ingress"

  vault_root = "secret/dm/square/${var.deploy_name}/${var.env_name}"

  grafana_oauth               = "${data.vault_generic_secret.grafana_oauth.data}"
  grafana_oauth_client_id     = "${var.grafana_oauth_client_id != "" ? var.grafana_oauth_client_id : local.grafana_oauth["client_id"]}"
  grafana_oauth_client_secret = "${var.grafana_oauth_client_secret != "" ? var.grafana_oauth_client_secret : local.grafana_oauth["client_secret"]}"

  grafana_admin_pass = "${random_string.grafana_admin_pass.result}"
  grafana_admin_user = "admin"

  prometheus_oauth               = "${data.vault_generic_secret.prometheus_oauth.data}"
  prometheus_oauth_client_id     = "${var.prometheus_oauth_client_id != "" ? var.prometheus_oauth_client_id : local.prometheus_oauth["client_id"]}"
  prometheus_oauth_client_secret = "${var.prometheus_oauth_client_secret != "" ? var.prometheus_oauth_client_secret : local.prometheus_oauth["client_secret"]}"

  tls     = "${data.vault_generic_secret.tls.data}"
  tls_crt = "${var.tls_crt!= "" ? var.tls_crt: local.tls["crt"]}"
  tls_key = "${var.tls_key!= "" ? var.tls_key: local.tls["key"]}"
}
