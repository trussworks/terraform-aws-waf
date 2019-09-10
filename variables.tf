variable "environment" {
  description = "Name of the environment to create (e.g., staging, prod, etc.)."
  type        = "string"
}

variable "associate_alb" {
  description = "Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL)."
  default     = false
  type        = "string"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL)."
  type        = "string"
}

variable "wafregional_rule_f5_id" {
  description = "The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with \"aws waf-regional list-subscribed-rule-groups\"."
  type        = "string"
}

variable "regex_path_disallow_pattern_strings" {
  description = "The list of URI paths to block using the WAF."
  type        = "list"
}

variable "regex_host_allow_pattern_strings" {
  description = "The list of hosts to allow using the WAF (as found in HTTP Header)."
  type        = "list"
}

variable "ip_rate_limit" {
  description = "The rate limit for IPs matching with a 5 minute window."
  type        = "string"
  default     = 2000
}
