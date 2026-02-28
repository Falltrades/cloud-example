module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = var.s3_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true

  versioning = {
    enabled = false
  }
}
