resource "aws_route53_record" "grafana" {
  count           = "${var.dns_enable ? 1 : 0}"
  zone_id         = "${var.aws_zone_id}"
  allow_overwrite = "${var.dns_overwrite}"

  name    = "${local.grafana_fqdn}"
  type    = "A"
  ttl     = "60"
  records = ["${local.nginx_ingress_ip}"]
}

resource "aws_route53_record" "prometheus" {
  count           = "${var.dns_enable ? 1 : 0}"
  zone_id         = "${var.aws_zone_id}"
  allow_overwrite = "${var.dns_overwrite}"

  name    = "${local.prometheus_fqdn}"
  type    = "A"
  ttl     = "60"
  records = ["${local.nginx_ingress_ip}"]
}
