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
 * resource "aws_wafregional_rate_based_rule" "ipratelimit" {
 *   name        = "app-global-ip-rate-limit"
 *   metric_name = "wafAppGlobalIpRateLimit"
 *   rate_key   = "IP"
 *   rate_limit = 2000
 * }
 *
 * module "waf" {
 *   source = "trussworks/waf/aws"
 *
 *   alb_arn                             = module.alb_web_containers.alb_arn
 *   associate_alb                       = true
 *   allowed_hosts                       = [var.domain_name]
 *   blocked_path_prefixes               = var.blocked_path_prefixes
 *   ip_sets                             = var.ip_sets
 *   rate_based_rules                    = var.rate_based_rules
 *   rules                               = var.rules
 *   wafregional_rule_f5_id              = var.wafregional_rule_id
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

resource "aws_wafregional_byte_match_set" "allowed_hosts" {
  name = format("%s-allowed-hosts", var.web_acl_name)

  dynamic "byte_match_tuples" {
    for_each = var.allowed_hosts
    content {

      # Even though the AWS Console web UI suggests a capitalized "host" data,
      # the data should be lower case as the AWS API will silently lowercase anyway.
      field_to_match {
        type = "HEADER"
        data = "host"
      }

      target_string = byte_match_tuples.value

      # See ByteMatchTuple for possible variable options.
      # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
      positional_constraint = "EXACTLY"

      # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
      # extra or non-standard whitespace
      # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
      text_transformation = "COMPRESS_WHITE_SPACE"
    }
  }
}

resource "aws_wafregional_rule" "allowed_hosts" {
  name        = format("%s-allowed-hosts", var.web_acl_name)
  metric_name = format("%sAllowedHosts", var.web_acl_metric_name)

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.allowed_hosts.id
    negated = true
  }
}

resource "aws_wafregional_byte_match_set" "blocked_path_prefixes" {
  name = format("%s-blocked-path-prefixes", var.web_acl_name)

  dynamic "byte_match_tuples" {
    for_each = var.blocked_path_prefixes
    content {
      field_to_match {
        type = "URI"
      }

      target_string = byte_match_tuples.value

      # See ByteMatchTuple for possible variable options.
      # See https://docs.aws.amazon.com/waf/latest/APIReference/API_ByteMatchTuple.html#WAF-Type-ByteMatchTuple-PositionalConstraint
      positional_constraint = "STARTS_WITH"

      # Use COMPRESS_WHITE_SPACE to prevent sneaking around regex filter with
      # extra or non-standard whitespace
      # See https://docs.aws.amazon.com/sdk-for-go/api/service/waf/#RegexMatchTuple
      text_transformation = "COMPRESS_WHITE_SPACE"
    }
  }
}

resource "aws_wafregional_rule" "blocked_path_prefixes" {
  name        = format("%s-blocked-path-prefixes", var.web_acl_name)
  metric_name = format("%sBlockedPathPrefixes", var.web_acl_metric_name)

  predicate {
    type    = "ByteMatch"
    data_id = aws_wafregional_byte_match_set.blocked_path_prefixes.id
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

  rule {
    type     = "REGULAR"
    rule_id  = aws_wafregional_rule.allowed_hosts.id
    priority = 1 + length(aws_wafregional_rule.ips.*.id)

    action {
      type = "BLOCK"
    }
  }

  rule {
    type     = "REGULAR"
    rule_id  = aws_wafregional_rule.blocked_path_prefixes.id
    priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1

    action {
      type = "BLOCK"
    }
  }

  dynamic "rule" {
    for_each = var.rate_based_rules
    content {
      type     = "RATE_BASED"
      rule_id  = rule.value
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + rule.key

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
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + length(var.rate_based_rules) + rule.key

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
      priority = 1 + length(aws_wafregional_rule.ips.*.id) + 1 + 1 + length(var.rate_based_rules) + (length(var.wafregional_rule_f5_id) > 0 ? 1 : 0) + rule.key

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
