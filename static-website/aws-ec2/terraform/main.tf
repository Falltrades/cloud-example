data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "nginx_instance" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = "t3.micro"
  availability_zone                    = "us-east-1a"
  subnet_id                            = module.vpc.private_subnet_objects[0].id
  vpc_security_group_ids               = [aws_security_group.nginx_sg.id]
  associate_public_ip_address          = false
  iam_instance_profile                 = aws_iam_instance_profile.ssm.name
  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name    = "nginx_instance"
    Project = "nginx"
  }
}
