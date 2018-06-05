resource "kubernetes_namespace" "pkgroot" {
  metadata {
    name = "${var.k8s_namespace}"
  }
}
