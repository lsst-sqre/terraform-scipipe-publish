resource "kubernetes_secret" "ssl_proxy" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "ssl-proxy-secret"
  }

  data {
    proxycert = "${file("${path.root}/lsst-certs/lsst.codes/2017/lsst.codes_chain.pem")}"
    proxykey  = "${file("${path.root}/lsst-certs/lsst.codes/2017/lsst.codes.key")}"
    dhparam   = "${file("${path.root}/dhparam.pem")}"
  }
}
