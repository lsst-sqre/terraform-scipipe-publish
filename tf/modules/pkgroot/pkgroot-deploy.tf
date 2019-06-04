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

resource "kubernetes_deployment" "pkgroot" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "pkgroot-deploy"

    labels {
      name = "pkgroot-deploy"
      app  = "pkgroot"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "pkgroot-deploy"
        app  = "pkgroot"
      }
    }

    template {
      metadata {
        labels {
          name = "pkgroot-deploy"
          app  = "pkgroot"
        }
      }

      spec {
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
            claim_name = "${kubernetes_persistent_volume_claim.pkgroot.metadata.0.name}"
          }
        }

        volume {
          name      = "${local.www_log_mount["name"]}"
          empty_dir = {}
        }

        volume {
          name = "s3sync-secrets"

          secret {
            secret_name = "${kubernetes_secret.s3sync.metadata.0.name}"
          }
        }
      } # spec
    } # template
  } # spec
}
