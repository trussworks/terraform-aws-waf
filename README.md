Creates a WAF and associates it with an Application Load Balancer (ALB)

Creates the following resources:

- Web Application Firewall (WAF)
- Links F5-managed OWASP rules for WAF to block common attacks
- Creates rule for WAF to block requests by source IP Address (**Note**: the list of blocked IPs are not managed by this module)
- Creates rule for WAF to block requests by path (as found in URI)
- Creates rule for WAF to allow requests by host (as found in HTTP Header)
- Attaches WAF to Application Load Balancer (ALB)

## Terraform Versions

Terraform 0.13 and newer. Pin module version to ~> 3.X. Submit pull-requests to master branch.

Terraform 0.12. Pin module version to ~> 2.X. Submit pull-requests to terraform012 branch.

## Usage

```hcl
resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "app-global-ip-rate-limit"
  metric_name = "wafAppGlobalIpRateLimit"
  rate_key   = "IP"
  rate_limit = 2000
}

module "waf" {
  source = "trussworks/waf/aws"

  alb_arn                             = module.alb_web_containers.alb_arn
  associate_alb                       = true
  allowed_hosts                       = [var.domain_name]
  blocked_path_prefixes               = var.blocked_path_prefixes
  ip_sets                             = var.ip_sets
  rate_based_rules                    = [aws_wafregional_rate_based_rule.ipratelimit.id]
  rules                               = var.rules
  wafregional_rule_f5_id              = var.wafregional_rule_id
  web_acl_metric_name                 = "wafAppHelloWorld"
  web_acl_name                        = "app-hello-world"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                | Version   |
| ----------------------------------- | --------- |
| [terraform](#requirement_terraform) | >= 0.13.0 |
| [aws](#requirement_aws)             | >= 3.0    |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 3.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                           | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_wafregional_byte_match_set.allowed_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_byte_match_set)         | resource |
| [aws_wafregional_byte_match_set.blocked_path_prefixes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_byte_match_set) | resource |
| [aws_wafregional_rule.allowed_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_rule)                             | resource |
| [aws_wafregional_rule.blocked_path_prefixes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_rule)                     | resource |
| [aws_wafregional_rule.ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_rule)                                       | resource |
| [aws_wafregional_web_acl.wafacl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl)                              | resource |
| [aws_wafregional_web_acl_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl_association)        | resource |

## Inputs

| Name                                                                                                | Description                                                                                                                                  | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_alb_arn"></a> [alb_arn](#input_alb_arn)                                              | ARN of the Application Load Balancer (ALB) to be associated with the Web Application Firewall (WAF) Access Control List (ACL).               | `string`       | n/a     |   yes    |
| <a name="input_allowed_hosts"></a> [allowed_hosts](#input_allowed_hosts)                            | The list of allowed host names as specified in HOST header.                                                                                  | `list(string)` | n/a     |   yes    |
| <a name="input_associate_alb"></a> [associate_alb](#input_associate_alb)                            | Whether to associate an Application Load Balancer (ALB) with an Web Application Firewall (WAF) Access Control List (ACL).                    | `bool`         | `false` |    no    |
| <a name="input_blocked_path_prefixes"></a> [blocked_path_prefixes](#input_blocked_path_prefixes)    | The list of URI path prefixes to block using the WAF.                                                                                        | `list(string)` | `[]`    |    no    |
| <a name="input_ip_sets"></a> [ip_sets](#input_ip_sets)                                              | List of sets of IP addresses to block.                                                                                                       | `list(string)` | `[]`    |    no    |
| <a name="input_rate_based_rules"></a> [rate_based_rules](#input_rate_based_rules)                   | List of IDs of Rate-Based Rules to add to this WAF. Only use this variable for rate-based rules. Use the "rules" variable for regular rules. | `list(string)` | `[]`    |    no    |
| <a name="input_rules"></a> [rules](#input_rules)                                                    | List of IDs of Rules to add to this WAF. Only use this variable for regular rules. Use the "rate_based_rules" variable for rate-based rules. | `list(string)` | `[]`    |    no    |
| <a name="input_wafregional_rule_f5_id"></a> [wafregional_rule_f5_id](#input_wafregional_rule_f5_id) | The ID of the F5 Rule Group to use for the WAF for the ALB. Find the id with "aws waf-regional list-subscribed-rule-groups".                 | `string`       | `""`    |    no    |
| <a name="input_web_acl_metric_name"></a> [web_acl_metric_name](#input_web_acl_metric_name)          | Metric name of the Web ACL                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_web_acl_name"></a> [web_acl_name](#input_web_acl_name)                               | Name of the Web ACL                                                                                                                          | `string`       | n/a     |   yes    |

## Outputs

| Name                                                              | Description                        |
| ----------------------------------------------------------------- | ---------------------------------- |
| <a name="output_waf_acl_id"></a> [waf_acl_id](#output_waf_acl_id) | WAF ACL ID generated by the module |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Upgrade Path

### 2.0.0 to 2.1.0

Version `2.1.0` removes the `ip_rate_limit` variables and replaces it with a `rate_based_rules` variable. The new variable accepts a list of `aws_wafregional_rate_based_rule` ids. This variables allows the Web ACL to use a global rate limit or provide custom rate limits for different paths.

```hcl
resource "aws_wafregional_rate_based_rule" "ipratelimit" {
  name        = "app-global-ip-rate-limit"
  metric_name = "wafAppGlobalIpRateLimit"

  rate_key   = "IP"
  rate_limit = 2000
}
```

Use `terraform state mv` to externalize the rate limit rule, e.g., `terraform state mv FOO.BAR.aws_wafregional_rate_based_rule.ipratelimit Foo.aws_wafregional_rate_based_rule.ipratelimit`.

Version `2.1.0` removes the `regex_host_allow_pattern_strings` variable and replaces it with a required `allowed_hosts` variable. That variable now takes a list of fully qualified domain names rather than regex strings. If you ALB supports multiple domain names, each domain name will need to be added to the list.

Version `2.1.0` removes the `regex_path_disallow_pattern_strings` variable and replaces it with an optional `blocked_path_prefixes` variable. That variable now takes a list of URI path prefixes rather than regex strings.

Version `2.1.0` adds the `rules` variable which accepts a list of rule ids, which will be appended to the internally-managed rules.

### 1.3.0 to 2.0.0

Version `2.0.0` removes the `environment` variable and adds `web_acl_metric_name` and `web_acl_name` variables to provide more control over naming. AWS WAF rules will be prefixed by the `web_acl_name` of their associated Web ACL to provide for easy visual sorting.

Version `2.0.0` replaces the `ip_set` variable with a `ip_sets` list variable, which accepts a list of `aws_wafregional_ipset` ids. This variable allows the Web ACL to pull from multiple lists of blocked ip addresses, such that you can combine a global blocked list, and application-specific lists. For example: `ip_sets = [resource.aws_wafregional_ipset.global.id, resource.aws_wafregional_ipset.helloworld.id]`.

During the initial upgrade to `2.0.0`, and if you add additional dynamic rules, you'll need to delete your web ACLs, as terraform cannot properly handle peer dependencies between Rules and Web ACLs. For convenience, you can use the `delete-web-acl` script in the scripts folder. For example: `scripts/delete-web-acl WEB_ACL_ID`. Once the Web ACL is deleted use terraform apply to recreate the Web ACL and associate with your resources as you had before. Deleting a Web ACL does not delete any associated resources, such as Application Load Balancers; however, it will leave the resources temporarily unprotected.

### 1.2.2 to 1.3.0

Version `1.3.0` removes the `aws_wafregional_ipset` `ips` resource from this module and requires a `ip_set` variable that accepts the id of an externally managed `aws_wafregional_ipset`. This allows for a common IP Set to be used by multiple Web Application Firewalls. If your IP Set does not contain any IP addresses, then no IP addresses are blocked. For example:

```hcl
resource "aws_wafregional_ipset" "global" {
  name = "app-global-blocked-ips"

  ip_set_descriptor {
    type  = "IPV4"
    value = "1.2.3.4/32"
  }

}
```

Use `terraform state mv` to externalize the IP Set, e.g., `terraform state mv FOO.BAR.aws_wafregional_ipset.ips Foo.aws_wafregional_ipset.ips`.

## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```shell
make test
```

Or with aws-vault:

```shell
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```
