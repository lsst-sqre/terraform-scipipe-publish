terraform {
  backend "s3" {}
}

provider "template" {
  version = "~> 1.0"
}

module "gke_publish" {
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
}

module "doxygen" {
  source       = "modules/doxygen"
  aws_zone_id  = "${var.aws_zone_id}"
  env_name     = "${var.env_name}"
  service_name = "doxygen"
  domain_name  = "${var.domain_name}"
}
