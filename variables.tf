variable "associate_alb" {
  description = "Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL)."
  type        = bool
  default     = false
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL)."
  type        = string
}

variable "wafregional_rule_f5_id" {
  description = "The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with \"aws waf-regional list-subscribed-rule-groups\"."
  type        = string
  default     = ""
}

variable "regex_path_disallow_pattern_strings" {
  description = "The list of URI paths to block using the WAF."
  type        = list(string)
}

variable "rate_based_rules" {
  description = "List of WAF Rate-based rules."
  type        = "list"
  default     = []
}

variable "rules" {
  description = "List of WAF rules."
  type        = "list"
  default     = []
}

variable "ip_sets" {
  description = "List of sets of IP addresses to block."
  type        = list(string)
  default     = []
}

variable "web_acl_name" {
  description = "Name of the Web ACL"
  type        = string
}

variable "web_acl_metric_name" {
  description = "Metric name of the Web ACL"
  type        = string
}
