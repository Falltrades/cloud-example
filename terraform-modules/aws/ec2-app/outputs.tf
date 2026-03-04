output "vpc_id" {
  description = "ID of the VPC created by this module"
  value       = module.vpc.vpc_id
}

output "private_subnet_objects" {
  description = "Private subnet objects from the VPC module"
  value       = module.vpc.private_subnet_objects
}

output "app_instance_id" {
  description = "ID of the app EC2 instance"
  value       = aws_instance.app.id
}

output "app_instance_private_ip" {
  description = "Private IP of the app EC2 instance"
  value       = aws_instance.app.private_ip
}

output "app_security_group_id" {
  description = "Security group ID attached to the app instance"
  value       = aws_security_group.app.id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile with SSM permissions"
  value       = aws_iam_instance_profile.ssm.name
}

# Expose AMI so callers can reuse it for extra instances
output "ubuntu_ami_id" {
  description = "Latest Ubuntu 22.04 AMI ID, exposed so callers can reuse it for extra instances"
  value       = data.aws_ami.ubuntu.id
}
