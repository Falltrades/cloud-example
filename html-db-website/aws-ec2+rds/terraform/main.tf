module "web" {                                                                             
  source          = "../../../terraform-modules/aws/ec2-app"
  project         = "html-db"
  app_port        = 8080
  aws_region      = var.aws_region
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # RDS needs at least 2 AZs for the group, even if single instance
  s3_bucket_name  = "html-db-ansible-bucket"
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

resource "aws_db_subnet_group" "db_subnets" {
  name       = "main-db-subnet-group"
  subnet_ids = [for s in module.web.private_subnet_objects : s.id]
}

resource "aws_route53_zone" "private" {
  name = "demo.internal"
  vpc {
    vpc_id = module.web.vpc_id
  }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.demo.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.postgres.address]
}

resource "aws_security_group" "db_sg" {
  vpc_id = module.web.vpc_id

  ingress {
    security_groups = [module.web.app_security_group_id]
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "PostgreSQL from App Instance"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "db_allow_all_egress"
  }

  tags = {
    Name    = "db_sg_worker"
    Project = "html-db"
  }
}
