#
# WAF
#

resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "app-global-ip-rate-limit"
  metric_name = "wafAppGlobalIpRateLimit"
  rate_key    = "IP"
  rate_limit  = 2000
}

module "waf" {
  source = "../../"

  alb_arn       = aws_lb.main.arn
  associate_alb = true

  blocked_path_prefixes = ["/admin", "/password"]
  allowed_hosts         = ["apples", "oranges"]

  rate_based_rules = [aws_wafregional_rate_based_rule.ipratelimit.id]

  web_acl_name        = var.waf_acl_name
  web_acl_metric_name = var.waf_acl_metric_name
}

#
# ALB
#

resource "aws_lb" "main" {
  internal           = true
  load_balancer_type = "application"
  subnets            = module.vpc.private_subnets

  tags = {
    Automation = "Terraform"
  }
}

#
# VPC
#

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"
  cidr    = "10.0.0.0/16"
  azs     = var.vpc_azs
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
