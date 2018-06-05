output "fqdn" {
  value = "${data.template_file.fqdn.rendered}"
}

output "EUPS_S3_BUCKET" {
  value = "${aws_s3_bucket.eups.id}"
}

output "EUPS_PUSH_USER" {
  value = "${module.push_user.name}"
}

output "EUPS_PUSH_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.push_user.id}"
}

output "EUPS_PUSH_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.push_user.secret}"
}

output "EUPS_PULL_USER" {
  value = "${module.pull_user.name}"
}

output "EUPS_PULL_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.pull_user.id}"
}

output "EUPS_PULL_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.pull_user.secret}"
}

output "EUPS_BACKUP_S3_BUCKET" {
  value = "${aws_s3_bucket.eups_backups.id}"
}

output "EUPS_BACKUP_USER" {
  value = "${module.backup_user.name}"
}

output "EUPS_BACKUP_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.backup_user.id}"
}

output "EUPS_BACKUP_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.backup_user.secret}"
}

output "EUPS_TAG_ADMIN_USER" {
  value = "${module.tag_admin_user.name}"
}

output "EUPS_TAG_ADMIN_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.tag_admin_user.id}"
}

output "EUPS_TAG_ADMIN_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.tag_admin_user.secret}"
}
