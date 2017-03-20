output "DOXYGEN_S3_BUCKET" {
  value = "${aws_s3_bucket.doxygen.id}"
}

output "DOXYGEN_PUSH_USER" {
  value = "${module.push-user.name}"
}

output "DOXYGEN_PUSH_AWS_ACCESS_KEY_ID" {
  sensitive = true
  value     = "${module.push-user.id}"
}

output "DOXYGEN_PUSH_AWS_SECRET_ACCESS_KEY" {
  sensitive = true
  value     = "${module.push-user.secret}"
}
