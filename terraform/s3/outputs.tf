output "EUPS_S3_BUCKET" {
  value = "${aws_s3_bucket.eups.id}"
}

output "EUPS_PUSH_USER" {
  value = "${module.push-user.name}"
}

output "EUPS_PUSH_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.push-user.id}"
}

output "EUPS_PUSH_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.push-user.secret}"
}

output "EUPS_PULL_USER" {
  value = "${module.pull-user.name}"
}

output "EUPS_PULL_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.pull-user.id}"
}

output "EUPS_PULL_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.pull-user.secret}"
}

output "EUPS_BACKUP_S3_BUCKET" {
  value = "${aws_s3_bucket.eups-backups.id}"
}

output "EUPS_BACKUP_USER" {
  value = "${module.backup-user.name}"
}

output "EUPS_BACKUP_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.backup-user.id}"
}

output "EUPS_BACKUP_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.backup-user.secret}"
}
