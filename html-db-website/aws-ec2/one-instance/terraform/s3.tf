module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket = "ansible-private-s3-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy            = true

  versioning = {
    enabled = false
  }
}
