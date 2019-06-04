resource "kubernetes_secret" "pkgroot_tls" {
  metadata {
    name      = "pkgroot-tls"
    namespace = "${var.k8s_namespace}"
  }

  data {
    tls.crt = "${local.tls_crt}"
    tls.key = "${local.tls_key}"
  }
}

resource "kubernetes_ingress" "pkgroot" {
  metadata {
    name      = "pkgroot-ingress"
    namespace = "${var.k8s_namespace}"

    labels {
      name = "pkgroot-ingress"
      app  = "pkgroot"
    }
  }

  spec {
    rule {
      host = "${local.fqdn}"

      http {
        path {
          backend {
            service_name = "pkgroot-service"
            service_port = 80
          }

          path = "/"
        }
      }
    } # rule

    tls {
      hosts       = ["${local.fqdn}"]
      secret_name = "${kubernetes_secret.pkgroot_tls.metadata.0.name}"
    }
  } # spec
}
