module "gke" {
  source = "github.com/lsst-sqre/terraform-gke-std"

  name               = "${local.gke_cluster_name}"
  google_project     = "${var.google_project}"
  gke_version        = "latest"
  initial_node_count = 3
  machine_type       = "n1-standard-1"
}

resource "null_resource" "gcloud_container_clusters_credentials" {
  triggers = {
    google_containre_cluster_endpoint = "${module.gke.id}"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${local.gke_cluster_name}"
  }

  depends_on = [
    "module.gke",
  ]
}

provider "kubernetes" {
  version = "~> 1.4"

  load_config_file = true

  host                   = "${module.gke.host}"
  cluster_ca_certificate = "${base64decode(module.gke.cluster_ca_certificate)}"
}

module "pkgroot" {
  source       = "modules/pkgroot"
  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "eups"
  domain_name  = "${var.domain_name}"

  k8s_namespace = "pkgroot"

  # prod s3 bucket is > 1TiB
  pkgroot_storage_size = "2Ti"

  proxycert = "${file("${path.root}/lsst-certs/lsst.codes/2018/lsst.codes_chain.pem")}"
  proxykey  = "${file("${path.root}/lsst-certs/lsst.codes/2018/lsst.codes.key")}"
  dhparam   = "${file("${path.root}/dhparam.pem")}"
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

  k8s_namespace = "pkgroot-redirect"

  proxycert = "${file("${path.root}/lsst-certs/sw.lsstcorp.org/sw.lsstcorp.org.20170530_chain.pem")}"
  proxykey  = "${file("${path.root}/lsst-certs/sw.lsstcorp.org/sw.lsstcorp.org.20170530.key")}"
  dhparam   = "${file("${path.root}/dhparam.pem")}"
}
