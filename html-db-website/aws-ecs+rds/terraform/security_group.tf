resource "aws_security_group" "alb_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    security_groups = [aws_security_group.alb_sg.id]
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    description     = "http from alb"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "app_allow_all_egress"
  }

  tags = {
    Name    = "app_sg_worker"
    Project = "html-db"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = module.vpc.vpc_id
 
  ingress {
    security_groups = [aws_security_group.app_sg.id]
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
