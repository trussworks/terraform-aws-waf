resource "aws_cloudformation_stack" "waf" {
  name = "waf-stack"
  parameters = {
    ProjectName = var.project,
    EnvName     = var.env
    WAFName     = "${var.project}-${var.env}-waf-web-acl"
    ALBARN      = var.alb
  }

  template_body = file("${path.module}/cloudformation.yaml")
}
