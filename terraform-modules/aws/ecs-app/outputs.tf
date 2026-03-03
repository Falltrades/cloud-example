output "website_dns" {
  description = "Public ALB DNS"
  value       = module.alb.dns_name
}

output "vpc_id" {
  description = "ID of the VPC created by this module"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (use for RDS subnet groups)"
  value       = module.vpc.private_subnets
}

output "private_subnet_objects" {
  description = "Private subnet objects, when you need CIDR or AZ alongside the ID"
  value       = module.vpc.private_subnet_objects
}

output "app_security_group_id" {
  description = "Security group ID attached to the ECS tasks"
  value       = aws_security_group.app.id
}
