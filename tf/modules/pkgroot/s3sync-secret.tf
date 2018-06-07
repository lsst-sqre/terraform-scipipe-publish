resource "kubernetes_secret" "s3sync" {
  metadata {
    namespace = "${var.k8s_namespace}"
    name      = "s3sync-secret"

    labels {
      name = "s3sync-secret"
      app  = "pkgroot"
    }
  }

  data {
    AWS_ACCESS_KEY_ID     = "${module.pull_user.id}"
    AWS_SECRET_ACCESS_KEY = "${module.pull_user.secret}"
    S3_BUCKET             = "${aws_s3_bucket.eups.id}"
  }
}
