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
  type        = list
}

variable "regex_host_allow_pattern_strings" {
  description = "The list of hosts to allow using the WAF (as found in HTTP Header)."
  type        = list
}

variable "ip_rate_limit" {
  description = "The rate limit for IPs matching with a 5 minute window."
  type        = number
  default     = 2000
}

variable "ip_sets" {
  description = "List of sets of IP addresses to block."
  type        = list
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
