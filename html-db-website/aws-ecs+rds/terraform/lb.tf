module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "10.5.0"

  name                       = "app-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward  = {
        target_group_key = "app-ecs"
      }
    }
  }

  target_groups = {
    app-ecs = {
      name_prefix = "ecs"
      protocol    = "HTTP"
      port        = 8080
      target_type = "ip"

      create_attachment = false
    }
  }

  tags = {
    Project = "html-db"
  }
}
