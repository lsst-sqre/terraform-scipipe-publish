resource "aws_route53_record" "pkgroot_www" {
  count   = "${var.dns_enable ? 1 : 0}"
  zone_id = "${var.aws_zone_id}"

  name    = "${local.fqdn}"
  type    = "A"
  ttl     = "60"
  records = ["${var.ingress_ip}"]
}
