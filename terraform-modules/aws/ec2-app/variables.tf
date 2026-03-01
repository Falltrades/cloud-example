variable "project" {
  description = "Project name used for naming/tagging"
  type        = string
}

variable "app_port" {
  description = "Port the app instance listens on"
  type        = number
  default     = 80
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "private_subnets" {
  description = "List of private subnet CIDRs, one per AZ. Provide at least 2 for RDS subnet group compatibility."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for the app instance"
  type    = string
  default = "t3.micro"
}

variable "s3_bucket_name" {
  description = "Name for the ansible S3 bucket"
  type        = string
}

# Optional: pass in extra instance IDs to attach to the ALB target group
# (e.g. if the caller wants to register a different instance)
variable "alb_target_instance_id" {
  description = "Instance ID to register in the ALB target group. Defaults to the app instance created by this module."
  type        = string
  default     = null  # null means use the module's own app instance
}
