/**
 * Creates a WAF and associates it with an Application Load Balancer (ALB)
 *
 * Creates the following resources:
 *
 * * Web Application Firewall (WAF)
 * * Links F5-managed OWASP rules for WAF to block common attacks
 * * Creates rule for WAF to block requests by source IP Address
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
 *   environment                         = "${var.environment}"
 *   associate_alb                       = true
 *   alb_arn                             = "${module.alb_web_containers.alb_arn}"
 *   wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
 *   ips_disallow                        = "${var.waf_ips_diallow}"
 *   regex_path_disallow_pattern_strings = "${var.waf_regex_path_disallow_pattern_strings}"
 *   regex_host_allow_pattern_strings    = "${var.waf_regex_host_allow_pattern_strings}"
 *   ip_rate_limit                       = 2000
 * }
 * ```
 */

resource "aws_wafregional_ipset" "ips" {
  name = "waf-app-${var.environment}-ips"

  lifecycle {
    ignore_changes = [
      "ip_set_descriptor",
    ]
  }
}

resource "aws_wafregional_rule" "ips" {
  depends_on = ["aws_wafregional_ipset.ips"]

  name        = "waf-app-${var.environment}-ips"
  metric_name = "wafApp${title(var.environment)}IPs"

  predicate {
    data_id = "${aws_wafregional_ipset.ips.id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "waf-app-${var.environment}-ipratelimit"
  metric_name = "wafApp${title(var.environment)}IpRateLimit"

  rate_key   = "IP"
  rate_limit = "${var.ip_rate_limit}"
}

resource "aws_wafregional_regex_pattern_set" "regex_uri" {
  name                  = "waf-app-${var.environment}-regex-uri"
  regex_pattern_strings = "${var.regex_path_disallow_pattern_strings}"
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

resource "aws_wafregional_regex_pattern_set" "regex_host" {
  name                  = "waf-app-${var.environment}-regex-host"
  regex_pattern_strings = "${var.regex_host_allow_pattern_strings}"
}

resource "aws_wafregional_regex_match_set" "regex_host" {
  name = "waf-app-${var.environment}-regex-host"

  regex_match_tuple {
    field_to_match {
      type = "HEADER"
      data = "Host"
    }

    regex_pattern_set_id = "${aws_wafregional_regex_pattern_set.regex_host.id}"

    # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
    # extra or non-standard whitespace
    # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
    text_transformation = "COMPRESS_WHITE_SPACE"
  }
}

resource "aws_wafregional_rule" "regex_host" {
  name        = "waf-app-${var.environment}-regex-host"
  metric_name = "wafApp${title(var.environment)}RegexHost"

  predicate {
    type    = "RegexMatch"
    data_id = "${aws_wafregional_regex_match_set.regex_host.id}"
    negated = true
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

  rule {
    type     = "REGULAR"
    rule_id  = "${aws_wafregional_rule.ips.id}"
    priority = 3

    action {
      type = "BLOCK"
    }
  }

  rule {
    type     = "REGULAR"
    rule_id  = "${aws_wafregional_rule.regex_host.id}"
    priority = 4

    action {
      type = "BLOCK"
    }
  }

  rule {
    type     = "RATE_BASED"
    rule_id  = "${aws_wafregional_rate_based_rule.ipratelimit.id}"
    priority = 5

    action {
      type = "BLOCK"
    }
  }
}

resource "aws_wafregional_web_acl_association" "main" {
  count        = "${var.associate_alb}"
  resource_arn = "${var.alb_arn}"
  web_acl_id   = "${aws_wafregional_web_acl.wafacl.id}"
}
