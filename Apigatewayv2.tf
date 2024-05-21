resource "aws_apigatewayv2_api" "bmt-prod" {
  name                       = "bmt-prod"
  api_key_selection_expression = "$request.header.x-api-key"
  protocol_type              = "HTTP"
  route_selection_expression = "$request.method $request.path"
  disable_execute_api_endpoint = false
}


resource "aws_apigatewayv2_api" "rat-prod" {
  name                       = "rat-prod"
  api_key_selection_expression = "$request.header.x-api-key"
  protocol_type              = "HTTP"
  route_selection_expression = "$request.method $request.path"
  disable_execute_api_endpoint = false
}


resource "aws_apigatewayv2_stage" "bmt-ApiGatewayV2Stage" {
  api_id = aws_apigatewayv2_api.bmt-prod.id
  name   = "$default"
  default_route_settings {
    detailed_metrics_enabled = false
  }
  auto_deploy = true
}


resource "aws_apigatewayv2_stage" "rat-ApiGatewayV2Stage" {
  api_id = aws_apigatewayv2_api.rat-prod.id
  name   = "$default"
  default_route_settings {
    detailed_metrics_enabled = false
  }
  auto_deploy = true
}



resource "aws_apigatewayv2_route" "bmt-route" {
  api_id    = aws_apigatewayv2_api.bmt-prod.id
  route_key = "ANY /{proxy+}"
  authorization_type = "NONE"
  api_key_required = false

  #target = "integrations/${aws_apigatewayv2_integration.example.id}"
}


resource "aws_apigatewayv2_route" "rat-route" {
  api_id    = aws_apigatewayv2_api.rat-prod.id
  route_key = "ANY /{proxy+}"
  authorization_type = "NONE"
  api_key_required = false

  #target = "integrations/${aws_apigatewayv2_integration.example.id}"
}


resource "aws_apigatewayv2_vpc_link" "bmt-rat-vpc-link" {
  name               = "bmt-rat-vpc-link"
  security_group_ids = [aws_security_group.ControlPlaneSecurityGroup.id]
  subnet_ids         = [
    aws_subnet.PublicSubnet01.id,
    aws_subnet.PublicSubnet02.id,
    aws_subnet.PrivateSubnet01.id,
    aws_subnet.PrivateSubnet02.id,
  ]
}