<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates a WAF and associates it with an Application Load Balancer (ALB)

Creates the following resources:

* Web Application Firewall (WAF)
* Links F5-managed OWASP rules for WAF to block common attacks
* Creates rule for WAF to block requests by source IP Address (**Note**: the list of blocked IPs are not managed by this module)
* Creates rule for WAF to block requests by path (as found in URI)
* Creates rule for WAF to allow requests by host (as found in HTTP Header)
* Attaches WAF to Application Load Balancer (ALB)

## Usage

```hcl
module "waf" {
  source = "trussworks/waf/aws"

  environment                         = "${var.environment}"
  associate_alb                       = true
  alb_arn                             = "${module.alb_web_containers.alb_arn}"
  wafregional_rule_f5_id              = "${var.wafregional_rule_id}"
  ips_disallow                        = "${var.waf_ips_diallow}"
  regex_path_disallow_pattern_strings = "${var.waf_regex_path_disallow_pattern_strings}"
  regex_host_allow_pattern_strings    = "${var.waf_regex_host_allow_pattern_strings}"
  ip_rate_limit                       = 2000
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_arn | ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL). | string | n/a | yes |
| associate\_alb | Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL). | string | `"false"` | no |
| environment | Name of the environment to create (e.g., staging, prod, etc.). | string | n/a | yes |
| ip\_rate\_limit | The rate limit for IPs matching with a 5 minute window. | string | `"2000"` | no |
| regex\_host\_allow\_pattern\_strings | The list of hosts to allow using the WAF (as found in HTTP Header). | list | n/a | yes |
| regex\_path\_disallow\_pattern\_strings | The list of URI paths to block using the WAF. | list | n/a | yes |
| wafregional\_rule\_f5\_id | The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with "aws waf-regional list-subscribed-rule-groups". | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
