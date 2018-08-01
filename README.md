Creates a WAF and associates it with an Application Load Balancer (ALB)

Creates the following resources:

* Web Application Firewall (WAF)
* Creates URI Regex Rule for WAF
* Attaches WAF to Application Load Balancer (ALB)


## Usage

```hcl
module "waf" {
  source = "./waf"

  environment                    = "${var.environment}"
  alb_arn                        = "${module.alb_web_containers.alb_arn}"
  wafregional_rule_f5_id         = "${var.wafregional_rule_id}"
  regex_disallow_pattern_strings = "${var.waf_regex_disallow_pattern_strings}"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb_arn | Application Load Balancer ARN | string | - | yes |
| environment | Name of the environment to create (e.g., staging, prod, etc.). | string | - | yes |
| regex_disallow_pattern_strings | The list of URI patterns to block using the WAF. | list | - | yes |
| wafregional_rule_f5_id | The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with "aws waf-regional list-subscribed-rule-groups" | string | - | yes |
