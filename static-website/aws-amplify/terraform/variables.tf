variable "aws_region" {
  description = "the AWS region"
  type        = string
  default     = "us-east-1"
}

variable "personal_access_token" {
  description = "personal access token for a third-party source control system"
  type        = string
  sensitive   = true
}
