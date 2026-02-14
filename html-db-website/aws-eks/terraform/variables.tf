variable "aws_region" {
  description = "the AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "DB Root username"
  type        = string
  sensitive   = true
}
 
variable "db_password" {
  description = "DB Root Password"
  type        = string
  sensitive   = true
}
 
variable "db_name" {
  description = "DB Root name"
  type        = string
  default     = "tasklist_db"
}
