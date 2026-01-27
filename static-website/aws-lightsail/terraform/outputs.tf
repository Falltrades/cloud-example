output "website_url" {
  description = "Public URL of the Lightsail nginx website"
  value       = aws_lightsail_container_service.nginx_container_service.url
}
