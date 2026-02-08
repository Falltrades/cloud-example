module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "7.2.0"

  cluster_name = "ecs-nginx"
  create_cloudwatch_log_group = false

  cluster_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 50
      base   = 20
    }
    FARGATE_SPOT = {
      weight = 50
    }
  }

  services = {
    ecs-nginx = {
      cpu    = 512
      memory = 2048
      container_definitions = {

        nginx = {
          cpu       = 512
          memory    = 1024
          image     = "ghcr.io/falltrades/cloud-example/html:1.0.0"
          portMappings = [
            {
              name          = "ecs-nginx"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]

          readonlyRootFilesystem = false
        }
      }

      subnet_ids         = module.vpc.private_subnets 
      security_group_ids = [aws_security_group.nginx_sg.id]
      enable_autoscaling = false

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["nginx-ecs"].arn
          container_name   = "nginx"
          container_port   = 8080
        }
      }
    }
  }

  tags = {
    Project = "nginx"
  }
}
