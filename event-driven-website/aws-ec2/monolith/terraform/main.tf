module "web" {
  source         = "../../../../terraform-modules/aws/ec2-app"
  project        = "event-driven"
  app_port       = 8080
  s3_bucket_name = "event-driven-ansible-bucket"
}
