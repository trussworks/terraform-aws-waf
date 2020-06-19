resource "aws_cloudformation_stack" "waf" {
  name = "waf-stack"
  parameters = {
    ProjectName = var.project,
    EnvName     = var.env
    WAFName     = "${var.env}-${var.project}-waf-web-acl"
    ALBARN      = var.alb
  }

  template_body = file("${path.module}/cloudformation.yaml")
}
