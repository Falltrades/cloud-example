module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "7.2.0"

  cluster_name = "ecs-app"
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
    ecs-app = {
      cpu    = 512
      memory = 2048
      container_definitions = {

        app = {
          cpu       = 512
          memory    = 1024
          image     = "ghcr.io/falltrades/cloud-example/html-db:1.0.0"
          portMappings = [
            {
              name          = "ecs-app"
              containerPort = 8080
              protocol      = "tcp"
            }
          ]

          readonlyRootFilesystem = false
          environment = [
                { name = "DATABASE_URL", value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:5432/${var.db_name}" }
              ]
            }
          }

      subnet_ids         = module.vpc.private_subnets 
      security_group_ids = [aws_security_group.app_sg.id]
      enable_autoscaling = false

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["app-ecs"].arn
          container_name   = "app"
          container_port   = 8080
        }
      }
    }
  }

  tags = {
    Project = "html-db"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  
  multi_az = false # Set to true for production high availability
  
  tags = {            
    Name    = "db_instance"
    Project = "html-db"
  }
}  
