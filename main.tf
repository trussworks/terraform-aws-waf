/**
 * Creates a WAF and associates it with an Application Load Balancer (ALB)
 *
 * Creates the following resources:
 *
 * * Web Application Firewall (WAF)
 * * Links F5-managed OWASP rules for WAF to block common attacks
 * * Creates rule for WAF to block requests by source IP Address (**Note**: the list of blocked IPs are not managed by this module)
 * * Creates rule for WAF to block requests by path (as found in URI)
 * * Creates rule for WAF to allow requests by host (as found in HTTP Header)
 * * Attaches WAF to Application Load Balancer (ALB)
 *

 * ## Usage
 *
 * ```hcl
 * module "waf" {
 *   source = "trussworks/waf/aws"
 *
 *   alb_arn                             = "${module.alb_web_containers.alb_arn}"
 *   associate_alb                       = true
 *   ip_rate_limit                       = 2000
 *   ip_sets                             = "${var.ip_sets}"
 *   regex_host_allow_pattern_strings    = "${var.waf_regex_host_allow_pattern_strings}"
 *   regex_path_disallow_pattern_strings = "${var.waf_regex_path_disallow_pattern_strings}"
 *   wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
 *   web_acl_metric_name                 = "wafAppHelloWorld"
 *   web_acl_name                        = "app-hello-world"
 * }
 * ```
 */

resource "aws_wafregional_rule" "ips" {
  count = length(var.ip_sets)

  name        = format("%s-ips-%d", var.web_acl_name, count.index)
  metric_name = format("%sIPs%d", var.web_acl_metric_name, count.index)

  predicate {
    data_id = var.ip_sets[count.index]
    negated = false
    type    = "IPMatch"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafregional_regex_pattern_set" "regex_uri" {
  name                  = format("%s-regex-uri", var.web_acl_name)
  regex_pattern_strings = var.regex_path_disallow_pattern_strings
}

resource "aws_wafregional_regex_match_set" "regex_uri" {
  name = format("%s-regex-uri", var.web_acl_name)

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
  name        = format("%s-regex-uri", var.web_acl_name)
  metric_name = format("%sRegexUri", var.web_acl_metric_name)

  predicate {
    type    = "RegexMatch"
    data_id = "${aws_wafregional_regex_match_set.regex_uri.id}"
    negated = false
  }
}

resource "aws_wafregional_web_acl" "wafacl" {
  name        = var.web_acl_name
  metric_name = var.web_acl_metric_name

  default_action {
    type = "ALLOW"
  }

  dynamic "rule" {
    for_each = aws_wafregional_rule.ips.*.id
    content {
      type     = "REGULAR"
      rule_id  = rule.value
      priority = 1 + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  dynamic "rule" {
    for_each = var.rate_based_rules
    content {
      type     = "RATE_BASED"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.wafregional_rule_f5_id) > 0 ? [var.wafregional_rule_f5_id] : []
    content {
      type     = "GROUP"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + length(var.rate_based_rules) + rule.key

      override_action {
        type = "NONE"
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      type     = "REGULAR"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + length(var.rate_based_rules) + (length(var.wafregional_rule_f5_id) > 0 ? 1 : 0) + rule.key

      action {
        type = "BLOCK"
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_wafregional_web_acl_association" "main" {
  count        = var.associate_alb ? 1 : 0
  resource_arn = "${var.alb_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.wafacl.id}"
}
