resource "aws_s3_bucket" "frontend" {
  bucket = "event-driven-public-s3-bucket"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  content      = templatefile("${path.module}/templates/index.html.tftpl", {
    api_url = aws_apigatewayv2_stage.default.invoke_url
  })
  content_type = "text/html"
  etag         = md5(templatefile("${path.module}/templates/index.html.tftpl", {
    api_url = aws_apigatewayv2_stage.default.invoke_url
  }))
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac"
  description                       = "OAC for Event Dashboard S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}
