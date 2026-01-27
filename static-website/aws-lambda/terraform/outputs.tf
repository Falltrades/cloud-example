output "api_url" {
  description = "Public URL of the Lightsail nginx website"
  value       = aws_apigatewayv2_api.http.api_endpoint 
}
