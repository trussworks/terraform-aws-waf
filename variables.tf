variable "environment" {
  description = "Name of the environment to create (e.g., staging, prod, etc.)."
  type        = "string"
}

variable "alb_arn" {
  description = "Application Load Balancer ARN"
  type        = "string"
}

variable "wafregional_rule_f5_id" {
  description = "The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with \"aws waf-regional list-subscribed-rule-groups\""
  type        = "string"
}

variable "regex_disallow_pattern_strings" {
  description = "The list of URI patterns to block using the WAF."
  type        = "list"
}

variable "ips_disallow" {
  description = "The list of IP addresses to block using the WAF."
  type        = "list"
  default     = []
}
