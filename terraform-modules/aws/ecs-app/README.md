<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 10.5.0 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | 7.2.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 6.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Port the container listens on | `number` | `8080` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | List of availability zones | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b"<br/>]</pre> | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | Container CPU units | `number` | `256` | no |
| <a name="input_container_environment"></a> [container\_environment](#input\_container\_environment) | Environment variables to pass to the container | `list(object({ name = string, value = string }))` | `[]` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image to run in the ECS service | `string` | n/a | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | Container memory in MB | `number` | `1024` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | ECS task CPU units | `number` | `512` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | ECS task memory in MB | `number` | `2048` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet CIDRs. Provide at least 2 for RDS subnet group compatibility. | `list(string)` | <pre>[<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used for naming and tagging | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnet CIDRs | `list(string)` | <pre>[<br/>  "10.0.101.0/24",<br/>  "10.0.102.0/24"<br/>]</pre> | no |
| <a name="input_sidecar_containers"></a> [sidecar\_containers](#input\_sidecar\_containers) | Sidecar container specifications to pass to the container\_definitions | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | Security group ID attached to the ECS tasks |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | List of private subnet IDs (use for RDS subnet groups) |
| <a name="output_private_subnet_objects"></a> [private\_subnet\_objects](#output\_private\_subnet\_objects) | Private subnet objects, when you need CIDR or AZ alongside the ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC created by this module |
| <a name="output_website_dns"></a> [website\_dns](#output\_website\_dns) | Public ALB DNS |
<!-- END_TF_DOCS -->