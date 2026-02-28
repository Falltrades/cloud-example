module "web" {
  source         = "../../../../terraform-modules/aws/ec2-app"
  project        = "html-db"
  app_port       = 8080
  s3_bucket_name = "html-db-ansible-bucket"
}
