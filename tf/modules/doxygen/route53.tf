resource "aws_route53_record" "doxygen_www" {
  zone_id = "${var.aws_zone_id}"

  name    = "${local.fqdn}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_s3_bucket.doxygen.website_endpoint}"]
}
