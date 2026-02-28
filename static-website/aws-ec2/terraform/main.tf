module "web" {
  source         = "../../../terraform-modules/aws/ec2-app"
  project        = "nginx"
  app_port       = 80
  s3_bucket_name = "ansible-private-s3-bucket"
}
