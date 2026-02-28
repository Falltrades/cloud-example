module "web" {
  source         = "../../../../terraform-modules/aws/ec2-app"
  project        = "html-db"
  app_port       = 8080
  aws_region     = var.aws_region
  s3_bucket_name = "html-db-ansible-bucket"
}

resource "aws_instance" "db" {
  ami                                  = module.web.ubuntu_ami_id
  instance_type                        = "t3.micro"
  availability_zone                    = "${var.aws_region}a"
  subnet_id                            = module.web.private_subnet_objects[0].id
  vpc_security_group_ids               = [aws_security_group.db.id]
  associate_public_ip_address          = false
  iam_instance_profile                 = module.web.iam_instance_profile_name
  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name = "db_instance",
    Project = "html-db"
  }
}

resource "aws_security_group" "db" {
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
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  tags = {
    Name = "db_sg_worker",
    Project = "html-db"
  }
}

resource "aws_route53_zone" "private" {
  name = "demo.internal"
  vpc  { vpc_id = module.web.vpc_id }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.demo.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.db.private_ip]
}
