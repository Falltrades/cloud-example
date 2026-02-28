locals {
  # Use caller-supplied instance or fall back to the module's own app instance
  target_instance_id = coalesce(var.alb_target_instance_id, aws_instance.app.id)
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "10.5.0"

  name                       = "${var.project}-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.alb.id]
  enable_deletion_protection = false

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward  = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = var.app_port
      target_type      = "instance"
      target_id        = local.target_instance_id
    }
  }

  tags = {
    Project = var.project
  }
}
