output "website_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
