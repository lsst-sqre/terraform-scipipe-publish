resource "kubernetes_service" "pkgroot" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "pkgroot-service"

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
