resource "aws_dynamodb_table" "connections" {
  name         = "EventDashboardConnections"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "event_history" {
  name         = "EventDashboardHistory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_apigatewayv2_api" "event_ws" {
  name                       = "event-driven-ws"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "connect" {
  api_id    = aws_apigatewayv2_api.event_ws.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_conn.id}"
}

resource "aws_apigatewayv2_route" "get_history" {
  api_id    = aws_apigatewayv2_api.event_ws.id
  route_key = "get_history"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_conn.id}"
}

resource "aws_apigatewayv2_route" "trigger" {
  api_id    = aws_apigatewayv2_api.event_ws.id
  route_key = "manual_trigger"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_trigger.id}"
}

resource "aws_apigatewayv2_route" "clear" {
  api_id    = aws_apigatewayv2_api.event_ws.id
  route_key = "clear_history"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_trigger.id}"
}

resource "aws_apigatewayv2_integration" "lambda_conn" {
  api_id           = aws_apigatewayv2_api.event_ws.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.on_connect.invoke_arn
}

resource "aws_apigatewayv2_integration" "lambda_trigger" {
  api_id           = aws_apigatewayv2_api.event_ws.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.trigger.invoke_arn
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id      = aws_apigatewayv2_api.event_ws.id
  description = "Main deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_route.connect,
    aws_apigatewayv2_route.trigger,
    aws_apigatewayv2_route.clear,
    aws_apigatewayv2_route.get_history
  ]
}

resource "aws_apigatewayv2_stage" "default" {
  api_id        = aws_apigatewayv2_api.event_ws.id
  name          = "dev"
  auto_deploy   = true
}

resource "aws_lambda_permission" "apigw_connect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.on_connect.function_name
  principal     = "apigateway.amazonaws.com"
}

locals {
  zip_path = "${path.module}/../app/lambda.zip"
}

resource "aws_lambda_function" "on_connect" {
  filename         = local.zip_path
  source_code_hash = filebase64sha256(local.zip_path)
  function_name    = "EventConnectHandler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "on_connect.handler"
  runtime          = "python3.11"
  timeout          = 15

  environment {
    variables = {
      CONN_TABLE = aws_dynamodb_table.connections.name
      HIST_TABLE = aws_dynamodb_table.event_history.name
    }
  }
}

resource "aws_lambda_function" "trigger" {
  filename         = local.zip_path
  source_code_hash = filebase64sha256(local.zip_path)
  function_name    = "EventTriggerHandler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "trigger_event.handler"
  runtime          = "python3.9"
  timeout          = 15

  environment {
    variables = {
      CONN_TABLE = aws_dynamodb_table.connections.name
      HIST_TABLE = aws_dynamodb_table.event_history.name
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "apigateway.amazonaws.com"
}
