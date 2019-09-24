provider "google" {
  version = "~> 2.7.0"

  project = "${var.google_project}"
  region  = "${var.google_region}"
  zone    = "${var.google_zone}"
}

provider "aws" {
  version = "~> 2.13.0"

  region = "${var.aws_primary_region}"
}

provider "vault" {
  version = "~> 1.8.0"
}

module "gke" {
  source = "git::https://github.com/lsst-sqre/terraform-gke-std?ref=2.x"

  name               = "${local.gke_cluster_name}"
  gke_version        = "${var.gke_version}"
  initial_node_count = 3
  machine_type       = "n1-standard-1"
}

provider "kubernetes" {
  version = "~> 1.7.0"

  load_config_file       = false
  host                   = "${module.gke.host}"
  cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
  token                  = "${module.gke.token}"
}

resource "kubernetes_namespace" "tiller" {
  metadata {
    name = "tiller"
  }
}

module "tiller" {
  source = "git::https://github.com/lsst-sqre/terraform-tinfoil-tiller.git?ref=0.9.x"

  namespace = "${kubernetes_namespace.tiller.metadata.0.name}"
}

provider "helm" {
  version = "~> 0.9.1"

  service_account = "${module.tiller.service_account}"
  namespace       = "${module.tiller.namespace}"
  install_tiller  = false

  kubernetes {
    load_config_file       = false
    host                   = "${module.gke.host}"
    cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
    token                  = "${module.gke.token}"
  }
}

resource "kubernetes_namespace" "pkgroot" {
  metadata {
    name = "pkgroot"
  }
}

module "pkgroot" {
  source = "modules/pkgroot"

  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "eups"
  domain_name  = "${var.domain_name}"
  dns_enable   = "${var.dns_enable}"

  k8s_namespace = "${kubernetes_namespace.pkgroot.metadata.0.name}"

  pkgroot_storage_size = "${var.pkgroot_storage_size}"

  tls_crt    = "${local.tls_crt}"
  tls_key    = "${local.tls_key}"
  ingress_ip = "${local.nginx_ingress_ip}"
}

module "doxygen" {
  source = "modules/doxygen"

  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "doxygen"
  domain_name  = "${var.domain_name}"
  dns_enable   = "${var.dns_enable}"
}
