module "web" {
  source          = "../../../terraform-modules/aws/ecs-app"
  project         = "html-db"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # RDS needs at least 2 AZs for the group, even if single instance
  container_image = "ghcr.io/falltrades/cloud-example/html-db:1.0.0"
  container_environment = [
    {
      name = "DATABASE_URL"
      value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:5432/${var.db_name}"
    }
  ]
}

resource "aws_security_group" "db" {
  vpc_id = module.web.vpc_id

  ingress {
    security_groups = [module.web.app_security_group_id]
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "PostgreSQL from app"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg",
    Project = "html-db"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = module.web.private_subnet_ids
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = false

  tags = {
    Name = "db-instance"
    Project = "html-db"
  }
}
