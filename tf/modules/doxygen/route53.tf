resource "aws_route53_record" "doxygen_www" {
  count   = "${var.dns_enable ? 1 : 0}"
  zone_id = "${var.aws_zone_id}"

  name    = "${local.fqdn}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_s3_bucket.doxygen.website_endpoint}"]
}
