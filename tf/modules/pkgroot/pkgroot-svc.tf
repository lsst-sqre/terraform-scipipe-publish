resource "kubernetes_service" "pkgroot" {
  metadata {
    name      = "pkgroot-service"
    namespace = "${var.k8s_namespace}"

    labels {
      name = "pkgroot-service"
      app  = "pkgroot"
    }
  }

  spec {
    selector {
      name = "pkgroot-deploy"
      app  = "pkgroot"
    }

    #type = "LoadBalancer"

    port {
      name = "http"
      port = 80

      target_port = 80
      protocol    = "TCP"
    }
  } # spec
}
