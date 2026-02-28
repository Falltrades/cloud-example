resource "aws_security_group" "alb" {
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

  tags = {
    Project = var.project
  }
}

resource "aws_security_group" "app" {
  vpc_id = module.vpc.vpc_id

  ingress {
    security_groups = [aws_security_group.alb.id]
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    description     = "http from alb"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "${var.project}-app-allow-all-egress"
  }

  tags = {
    Name    = "${var.project}-app-sg"
    Project = var.project
  }
}
