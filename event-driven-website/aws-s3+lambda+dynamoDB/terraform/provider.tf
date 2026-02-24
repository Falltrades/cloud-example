terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = false
  skip_metadata_api_check     = false
  skip_requesting_account_id  = true
}
