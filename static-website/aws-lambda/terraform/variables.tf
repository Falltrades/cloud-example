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
