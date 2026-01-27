variable "aws_region" {
  description = "the AWS region"
  type        = string
  default     = "us-east-1"
}

variable "service_name" {
  description = "Lightsail container service name"
  type        = string
  default     = "nginx"
}

variable "container_image" {
  description = "Docker image"
  type        = string
  default     = "ghcr.io/falltrades/cloud-example:nginx"
}

