output "website_url" {
  description = "Public URL of the S3 static website"
  value       = "http://${module.s3_bucket.s3_bucket_website_endpoint}"
}
