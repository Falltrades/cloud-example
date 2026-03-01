module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = var.private_subnets
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  tags = {
    Project = var.project
  }
}
