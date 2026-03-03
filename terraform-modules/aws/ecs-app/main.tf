module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "7.2.0"

  cluster_name                = "${var.project}-ecs"
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
    app = {
      cpu    = var.cpu
      memory = var.memory

      container_definitions = merge(
        {
          app = {
            cpu       = var.container_cpu
            memory    = var.container_memory
            image     = var.container_image
            environment = var.container_environment
            portMappings = [
              {
                name          = "${var.project}-app"
                containerPort = var.app_port
                protocol      = "tcp"
              }
            ]
            readonlyRootFilesystem = false
          }
        },
        var.sidecar_containers
      )

      subnet_ids         = module.vpc.private_subnets
      security_group_ids = [aws_security_group.app.id]
      enable_autoscaling = false

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["app"].arn
          container_name   = "app"
          container_port   = var.app_port
        }
      }
    }
  }

  tags = {
    Project = var.project
  }
}
