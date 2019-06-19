<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_arn | ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL). | string | n/a | yes |
| associate\_alb | Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL). | string | `"false"` | no |
| environment | Name of the environment to create (e.g., staging, prod, etc.). | string | n/a | yes |
| ip\_rate\_limit | The rate limit for IPs matching with a 5 minute window. | string | `"2000"` | no |
| ips\_disallow | The list of IP addresses to block using the WAF. | list(string) | `[]` | no |
| regex\_host\_allow\_pattern\_strings | The list of hosts to allow using the WAF (as found in HTTP Header). | list(string) | n/a | yes |
| regex\_path\_disallow\_pattern\_strings | The list of URI paths to block using the WAF. | list(string) | n/a | yes |
| wafregional\_rule\_f5\_id | The ID of the F5 Rule Group to use for the WAF for the ALB.  Find the id with "aws waf-regional list-subscribed-rule-groups". | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
