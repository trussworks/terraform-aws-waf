/**
 * Creates a WAF and associates it with an Application Load Balancer (ALB)
 *
 * Creates the following resources:
 *
 * * Web Application Firewall (WAF)
 * * Creates URI Regex Rule for WAF
 * * Attaches WAF to Application Load Balancer (ALB)
 *

 * ## Usage
 *
 * ```hcl
 * module "waf" {
 *   source = "./waf"
 *
 *   environment                    = "${var.environment}"
 *   alb_arn                        = "${module.alb_web_containers.alb_arn}"
 *   wafregional_rule_f5_id         = "${var.wafregional_rule_id}"
 *   regex_disallow_pattern_strings = "${var.waf_regex_disallow_pattern_strings}"
 * }
 * ```
 */

resource "aws_wafregional_regex_pattern_set" "regex_uri" {
  name                  = "waf-app-${var.environment}-regex-uri"
  regex_pattern_strings = "${var.regex_disallow_pattern_strings}"
}

resource "aws_wafregional_regex_match_set" "regex_uri" {
  name = "waf-app-${var.environment}-regex-uri"

  regex_match_tuple {
    field_to_match {
      type = "URI"
    }

    regex_pattern_set_id = "${aws_wafregional_regex_pattern_set.regex_uri.id}"

    # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
    # extra or non-standard whitespace
    # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
    text_transformation = "COMPRESS_WHITE_SPACE"
  }
}

resource "aws_wafregional_rule" "regex_uri" {
  name        = "waf-app-${var.environment}-regex-uri"
  metric_name = "wafApp${title(var.environment)}RegexUri"

  predicate {
    type    = "RegexMatch"
    data_id = "${aws_wafregional_regex_match_set.regex_uri.id}"
    negated = false
  }
}

resource "aws_wafregional_web_acl" "wafacl" {
  name        = "waf-app-${var.environment}"
  metric_name = "wafApp${title(var.environment)}"

  default_action {
    type = "ALLOW"
  }

  rule {
    type     = "GROUP"
    rule_id  = "${var.wafregional_rule_f5_id}"
    priority = 1

    override_action {
      type = "NONE"
    }
  }

  rule {
    type     = "REGULAR"
    rule_id  = "${aws_wafregional_rule.regex_uri.id}"
    priority = 2

    action {
      type = "BLOCK"
    }
  }
}

resource "aws_wafregional_web_acl_association" "main" {
  resource_arn = "${var.alb_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.wafacl.id}"
}
