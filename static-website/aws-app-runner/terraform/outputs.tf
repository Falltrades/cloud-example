output "website_url" {
  description = "Public URL of the App Runner nginx website"
  value       = "https://${aws_apprunner_service.nginx.service_url}"
}
