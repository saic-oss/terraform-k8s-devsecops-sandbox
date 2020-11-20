resource "aws_route53_record" "gitlab" {
  name    = var.gitlab_host_name
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = true
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
  }
}

resource "aws_route53_record" "registry" {
  name    = var.registry_host_name
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = true
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
  }
}

resource "aws_route53_record" "minio" {
  name    = var.minio_host_name
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = true
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
  }
}

resource "aws_route53_record" "jenkins" {
  name    = var.jenkins_host_name
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = true
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
  }
}
