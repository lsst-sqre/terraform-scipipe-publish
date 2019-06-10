resource "vault_generic_secret" "scipipe_publish" {
  path = "secret/dm/square/jenkins/${var.env_name}/scipipe-publish"

  data_json = <<EOT
{
  "doxygen_fqdn": "${module.doxygen.fqdn}",
  "doxygen_url": "http://${module.doxygen.fqdn}",
  "doxygen_s3_bucket": "${module.doxygen.DOXYGEN_S3_BUCKET}",
  "doxygen_push_user": "${module.doxygen.DOXYGEN_PUSH_USER}",
  "doxygen_push_aws_access_key_id": "${module.doxygen.DOXYGEN_PUSH_AWS_ACCESS_KEY_ID}",
  "doxygen_push_aws_secret_access_key": "${module.doxygen.DOXYGEN_PUSH_AWS_SECRET_ACCESS_KEY}",
  "eups_fqdn": "${module.pkgroot.fqdn}",
  "eups_url": "https://${module.pkgroot.fqdn}",
  "eups_s3_bucket": "${module.pkgroot.EUPS_S3_BUCKET}",
  "eups_push_user": "${module.pkgroot.EUPS_PUSH_USER}",
  "eups_push_aws_access_key_id": "${module.pkgroot.EUPS_PUSH_AWS_ACCESS_KEY_ID}",
  "eups_push_aws_secret_access_key": "${module.pkgroot.EUPS_PUSH_AWS_SECRET_ACCESS_KEY}",
  "eups_pull_user": "${module.pkgroot.EUPS_PULL_USER}",
  "eups_pull_aws_access_key_id": "${module.pkgroot.EUPS_PULL_AWS_ACCESS_KEY_ID}",
  "eups_pull_aws_secret_access_key": "${module.pkgroot.EUPS_PULL_AWS_SECRET_ACCESS_KEY}",
  "eups_backup_s3_bucket": "${module.pkgroot.EUPS_BACKUP_S3_BUCKET}",
  "eups_backup_user": "${module.pkgroot.EUPS_BACKUP_USER}",
  "eups_backup_aws_access_key_id": "${module.pkgroot.EUPS_BACKUP_AWS_ACCESS_KEY_ID}",
  "eups_backup_aws_secret_access_key": "${module.pkgroot.EUPS_BACKUP_AWS_SECRET_ACCESS_KEY}",
  "eups_tag_admin_user": "${module.pkgroot.EUPS_TAG_ADMIN_USER}",
  "eups_tag_admin_aws_access_key_id": "${module.pkgroot.EUPS_TAG_ADMIN_AWS_ACCESS_KEY_ID}",
  "eups_tag_admin_aws_secret_access_key": "${module.pkgroot.EUPS_TAG_ADMIN_AWS_SECRET_ACCESS_KEY}"
}
EOT
}
