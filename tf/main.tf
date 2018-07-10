terraform {
  backend "s3" {}
}

provider "template" {
  version = "~> 1.0"
}

module "gke" {
  source             = "github.com/lsst-sqre/terraform-gke-std"
  name               = "${data.template_file.gke_cluster_name.rendered}"
  google_project     = "${var.google_project}"
  initial_node_count = 3
}

module "pkgroot" {
  source       = "modules/pkgroot"
  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "eups"
  domain_name  = "${var.domain_name}"

  k8s_namespace              = "pkgroot"
  k8s_host                   = "${module.gke.host}"
  k8s_client_certificate     = "${module.gke.client_certificate}"
  k8s_client_key             = "${module.gke.client_key}"
  k8s_cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"

  # prod s3 bucket is > 1TiB
  pkgroot_storage_size = "2Ti"
}

module "doxygen" {
  source       = "modules/doxygen"
  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "doxygen"
  domain_name  = "${var.domain_name}"
}

module "pkgroot-redirect" {
  source       = "github.com/lsst-sqre/terraform-pkgroot-redirect//tf?ref=master"
  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "eups-redirect"
  domain_name  = "${var.domain_name}"

  k8s_namespace              = "pkgroot-redirect"
  k8s_host                   = "${module.gke.host}"
  k8s_client_certificate     = "${module.gke.client_certificate}"
  k8s_client_key             = "${module.gke.client_key}"
  k8s_cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"

  proxycert = "${file("${path.root}/lsst-certs/sw.lsstcorp.org/sw.lsstcorp.org.20170530_chain.pem")}"
  proxykey  = "${file("${path.root}/lsst-certs/sw.lsstcorp.org/sw.lsstcorp.org.20170530.key")}"
  dhparam   = "${file("${path.root}/dhparam.pem")}"
}
