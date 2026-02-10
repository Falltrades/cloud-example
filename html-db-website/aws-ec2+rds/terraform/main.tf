data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_instance" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = "t3.micro"
  availability_zone                    = "us-east-1a"
  subnet_id                            = module.vpc.private_subnet_objects[0].id
  vpc_security_group_ids               = [aws_security_group.app_sg.id]
  associate_public_ip_address          = false
  iam_instance_profile                 = aws_iam_instance_profile.ssm.name
  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name    = "app_instance"
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
