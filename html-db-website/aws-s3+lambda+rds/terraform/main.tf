locals {
  zip_path = "${path.module}/../app/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.11"
  handler       = "app.handler"

  filename         = local.zip_path
  source_code_hash = filebase64sha256(local.zip_path)

  timeout = 15

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DATABASE_URL = "postgresql+pg8000://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}/${var.db_name}"
    }
  }
}

resource "aws_apigatewayv2_api" "http" {
  name          = "${var.function_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.s3_distribution.domain_name}"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_tasks" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "GET /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "post_tasks" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_db_subnet_group" "db" {
  name       = "main"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}
