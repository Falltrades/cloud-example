variable "project" {
  description = "Project name used for naming and tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "Docker image to run in the ECS service"
  type        = string
}

variable "cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 512
}

variable "memory" {
  description = "ECS task memory in MB"
  type        = number
  default     = 2048
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Container memory in MB"
  type        = number
  default     = 1024
}

variable "container_environment" {
  description = "Environment variables to pass to the container"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "sidecar_containers" {
  description = "Sidecar container specifications to pass to the container_definitions"
  type        = any
  default     = []
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs. Provide at least 2 for RDS subnet group compatibility."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}
