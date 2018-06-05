resource "kubernetes_persistent_volume_claim" "pkgroot" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "pkgroot-pvc"

    labels {
      name = "pkgroot-pvc"
      app  = "pkgroot"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "pd-ssd"

    resources {
      requests {
        storage = "${var.pkgroot_storage_size}"
      }
    }
  }
}
