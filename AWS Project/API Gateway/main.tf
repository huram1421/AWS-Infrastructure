# api gateway
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "API_Gateway"
  protocol_type = "HTTP"
}

# api stage
resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name        = "api_gateway_stage"
  auto_deploy = true
}


# api integrtion
resource "aws_apigatewayv2_integration" "DriverLambda_api_integration" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  integration_uri    = var.DriverLambdaArn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"    # REST API communication between API Gateway and Lambda
}
resource "aws_apigatewayv2_integration" "RiderLambda_api_integration" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  integration_uri    = var.RiderLambdaArn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"    # REST API communication between API Gateway and Lambda
}

# api routes
resource "aws_apigatewayv2_route" "DriverLambda_route" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /lambda/DriverLambda"
  target    = "integrations/${aws_apigatewayv2_integration.DriverLambda_api_integration.id}"
}
resource "aws_apigatewayv2_route" "RiderLambda_route" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /lambda/RiderLambda"
  target    = "integrations/${aws_apigatewayv2_integration.RiderLambda_api_integration.id}"
}

# permissions
resource "aws_lambda_permission" "api_gateway_DriverLambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.DriverLambdaName
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}
resource "aws_lambda_permission" "api_gateway_RiderLambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.RiderLambdaName
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}
