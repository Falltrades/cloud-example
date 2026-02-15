variable "aws_region" {
  description = "the AWS region"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "the name of the function"
  type        = string
  default     = "flask-lambda"
}

variable "db_username" {
  description = "RDS Root username"
  type        = string
  sensitive   = true
}
 
variable "db_password" {
  description = "RDS Root Password"
  type        = string
  sensitive   = true
}
 
variable "db_name" {
  description = "RDS Root username"
  type        = string
  default     = "tasklist_db"
}
