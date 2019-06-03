provider "google" {
  version = "~> 1.20"
}

provider "null" {
  version = "~> 1.0"
}

provider "aws" {
  version = "~> 1.54"

  region = "${var.aws_primary_region}"
}

module "gke" {
  source = "github.com/lsst-sqre/terraform-gke-std"

  name               = "${local.gke_cluster_name}"
  google_project     = "${var.google_project}"
  google_region      = "${var.google_region}"
  google_zone        = "${var.google_zone}"
  gke_version        = "${var.gke_version}"
  initial_node_count = 3
  machine_type       = "n1-standard-1"
}

provider "kubernetes" {
  # 1.5.0 changes podspec and wants to remove privileged from rc(s) without
  # syntax changes
  version = "~> 1.4.0"

  load_config_file = true

  host                   = "${module.gke.host}"
  cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
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

  proxycert = "${local.tls_crt}"
  proxykey  = "${local.tls_key}"
  dhparam   = "${local.tls_dhparam}"
}

module "doxygen" {
  source = "modules/doxygen"

  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "doxygen"
  domain_name  = "${var.domain_name}"
  dns_enable   = "${var.dns_enable}"
}
