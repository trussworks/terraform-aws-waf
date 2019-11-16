variable "alb_arn" {
  description = "ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL)."
  type        = string
}

variable "allowed_hosts" {
  description = "The list of allowed host names as specified in HOST header."
  type        = list(string)
}

variable "associate_alb" {
  description = "Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL)."
  type        = bool
  default     = false
}

variable "blocked_path_prefixes" {
  description = "The list of URI path prefixes to block using the WAF."
  type        = list(string)
  default     = []
}

variable "ip_sets" {
  description = "List of sets of IP addresses to block."
  type        = list(string)
  default     = []
}

variable "rate_based_rules" {
  description = "List of IDs of Rate-Based Rules to add to this WAF.  Only use this variable for rate-based rules.  Use the \"rules\" variable for regular rules."
  type        = list(string)
  default     = []
}

variable "rules" {
  description = "List of IDs of Rules to add to this WAF.  Only use this variable for regular rules.  Use the \"rate_based_rules\" variable for rate-based rules."
  type        = list(string)
  default     = []
}

variable "wafregional_rule_f5_id" {
  description = "The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with \"aws waf-regional list-subscribed-rule-groups\"."
  type        = string
  default     = ""
}

variable "web_acl_name" {
  description = "Name of the Web ACL"
  type        = string
}

variable "web_acl_metric_name" {
  description = "Metric name of the Web ACL"
  type        = string
}
