resource "kubernetes_secret" "ssl_proxy" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "ssl-proxy-secret"
  }

  data {
    proxycert = "${var.proxycert}"
    proxykey  = "${var.proxykey}"
    dhparam   = "${var.dhparam}"
  }
}
