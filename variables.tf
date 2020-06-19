variable "namespace" {
  type        = string
  default     = "ontex"
  description = "Name of the company"
}

variable "env" {
  type        = string
  description = "Environment name (production, development, staging)"
}

variable "alb" {
  type        = string
  description = "ALB to be protected with WAF"
}

variable "tags" {
  type        = any
  description = "List of tags to apply to the resource"
}

variable "project" {
  type        = string
  description = "Project code for the resource"
}

variable "region" {
  type        = string
  description = "AWS region"
}