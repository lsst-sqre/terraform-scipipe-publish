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

        volume_mount {
          name       = "pkgroot-storage"
          mount_path = "/var/www/html"
        }

        volume_mount {
          name       = "apache-logs"
          mount_path = "/var/log/apache2"
        }
      } # container

      # https://kubernetes.io/docs/concepts/cluster-administration/logging/#streaming-sidecar-container
      container {
        name  = "apache-access"
        image = "busybox"
        args  = ["/bin/sh", "-c", "tail -n+1 -f /var/log/apache2/access.log"]

        volume_mount {
          name       = "apache-logs"
          mount_path = "/var/log/apache2"
        }
      } # container

      container {
        name  = "apache-error"
        image = "busybox"
        args  = ["/bin/sh", "-c", "tail -n+1 -f /var/log/apache2/error.log"]

        volume_mount {
          name       = "apache-logs"
          mount_path = "/var/log/apache2"
        }
      } # container

      container {
        name              = "s3sync"
        image             = "lsstsqre/s3sync"
        image_pull_policy = "Always"

        security_context {
          privileged = true
        }

        volume_mount {
          name       = "s3sync-secrets"
          mount_path = "/etc/secrets"
          read_only  = true
        }

        volume_mount {
          name       = "pkgroot-storage"
          mount_path = "/var/www/html"
        }
      } # container

      volume {
        name = "pkgroot-storage"

        persistent_volume_claim {
          claim_name = "pkgroot-pvc"
        }
      }

      volume {
        name      = "apache-logs"
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
  ]
}
