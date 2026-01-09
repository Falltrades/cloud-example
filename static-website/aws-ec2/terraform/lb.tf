module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "nginx-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward  = {
        target_group_key = "nginx-instance"
      }
    }
  }

  target_groups = {
    nginx-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = aws_instance.nginx_instance.id 
    }
  }

  tags = {
    Project = "nginx"
  }
}
