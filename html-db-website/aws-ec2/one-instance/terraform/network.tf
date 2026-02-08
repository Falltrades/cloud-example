module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "nginx-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  tags = {
    Project = "nginx"
  }
}
