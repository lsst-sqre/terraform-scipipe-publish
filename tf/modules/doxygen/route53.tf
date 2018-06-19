resource "aws_route53_record" "doxygen_www" {
  zone_id = "${var.aws_zone_id}"

  # remove "<env>-" prefix for production
  name    = "${data.template_file.fqdn.rendered}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_s3_bucket.doxygen.website_endpoint}"]
}
