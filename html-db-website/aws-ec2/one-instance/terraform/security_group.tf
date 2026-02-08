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

resource "aws_security_group" "nginx_sg" {
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
    description = "nginx_allow_all_egress"
  }

  tags = {
    Name    = "nginx_sg_worker"
    Project = "nginx"
  }
}
