data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app" {
  ami                                  = data.aws_ami.ubuntu.id
  instance_type                        = var.instance_type
  availability_zone                    = "${var.aws_region}a"
  subnet_id                            = module.vpc.private_subnet_objects[0].id
  vpc_security_group_ids               = [aws_security_group.app.id]
  associate_public_ip_address          = false
  iam_instance_profile                 = aws_iam_instance_profile.ssm.name
  instance_initiated_shutdown_behavior = "terminate"

  tags = {
    Name    = "${var.project}-app-instance"
    Project = var.project
  }
}
