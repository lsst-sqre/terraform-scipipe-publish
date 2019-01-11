locals {
  log_sidecar_image = "busybox"
  www_server        = "apache"
  www_log_root      = "/var/log/apache2"
  www_log_access    = "${local.www_log_root}/access.log"
  www_log_error     = "${local.www_log_root}/error.log"

  www_log_mount = {
    name       = "${local.www_server}-logs"
    mount_path = "${local.www_log_root}"
  }

  pkgroot_mount = {
    name       = "pkgroot-storage"
    mount_path = "/var/www/html"
  }
}

resource "kubernetes_replication_controller" "pkgroot" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "pkgroot-rc"

    labels {
      name = "pkgroot-rc"
      app  = "pkgroot"
    }
  }

  spec {
    selector {
      name = "pkgroot-rc"
      app  = "pkgroot"
    }

    replicas = 1

    template {
      container {
        name              = "apache"
        image             = "eboraas/apache"
        image_pull_policy = "Always"

        port {
          name           = "pkgroot-apache"
          container_port = 80
        }

        volume_mount = [
          "${local.pkgroot_mount}",
          "${local.www_log_mount}",
        ]
      } # container

      # https://kubernetes.io/docs/concepts/cluster-administration/logging/#streaming-sidecar-container
      container {
        name  = "apache-access"
        image = "${local.log_sidecar_image}"
        args  = ["/bin/sh", "-c", "tail -n+1 -f /var/log/apache2/access.log"]

        volume_mount = ["${local.www_log_mount}"]
      } # container

      container {
        name  = "apache-error"
        image = "${local.log_sidecar_image}"
        args  = ["/bin/sh", "-c", "tail -n+1 -f /var/log/apache2/error.log"]

        volume_mount = ["${local.www_log_mount}"]
      } # container

      container {
        name              = "s3sync"
        image             = "lsstsqre/s3sync"
        image_pull_policy = "Always"

        security_context {
          privileged = true
        }

        volume_mount = [
          {
            name       = "s3sync-secrets"
            mount_path = "/etc/secrets"
            read_only  = true
          },
          "${local.pkgroot_mount}",
        ]
      } # container

      volume {
        name = "${local.pkgroot_mount["name"]}"

        persistent_volume_claim {
          claim_name = "pkgroot-pvc"
        }
      }

      volume {
        name      = "${local.www_log_mount["name"]}"
        empty_dir = {}
      }

      volume {
        name = "s3sync-secrets"

        secret {
          secret_name = "s3sync-secret"
        }
      }
    } # template
  } # spec

  depends_on = [
    # attempt to avoid startup crashes due to missing env vars
    "kubernetes_secret.s3sync",

    # attempt to force the rc/pods to be destroyed first
    "kubernetes_persistent_volume_claim.pkgroot",
  ]
}
