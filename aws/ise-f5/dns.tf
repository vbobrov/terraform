data "aws_route53_zone" "ciscodemo" {
  name = "aws.ciscodemo.net."
}

resource "aws_route53_record" "mgm" {
  zone_id = data.aws_route53_zone.ciscodemo.id
  name    = "mgm-ise"
  type    = "A"
  ttl     = "15"
  records = [aws_instance.mgm.public_ip]
}

resource "aws_route53_record" "ise" {
  count   = var.ise_count
  zone_id = data.aws_route53_zone.ciscodemo.id
  name    = "ise-${count.index + 1}"
  type    = "A"
  ttl     = "15"
  records = [aws_instance.ise[count.index].private_ip]
}