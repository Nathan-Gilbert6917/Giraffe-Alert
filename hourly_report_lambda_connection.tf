resource "aws_api_gateway_resource" "hourly_report_resource" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    parent_id   = aws_api_gateway_rest_api.giraffe_api.root_resource_id
    path_part   = "hourly_report"
}

resource "aws_api_gateway_method" "hourly_report_options_method" {
    rest_api_id   = aws_api_gateway_rest_api.giraffe_api.id
    resource_id   = aws_api_gateway_resource.hourly_report_resource.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "hourly_report_options_integration" {
    rest_api_id             = aws_api_gateway_rest_api.giraffe_api.id
    resource_id             = aws_api_gateway_resource.hourly_report_resource.id
    http_method             = aws_api_gateway_method.hourly_report_options_method.http_method
    integration_http_method = "OPTIONS"
    type                    = "MOCK"

    request_templates = {
        "application/json" = "{\"statusCode\": 200}"
    }
}

resource "aws_api_gateway_method_response" "hourly_report_options_response" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = aws_api_gateway_method.hourly_report_options_method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true
    }
}

resource "aws_api_gateway_integration_response" "hourly_report_options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = aws_api_gateway_method.hourly_report_options_method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
        "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,PUT,POST,DELETE,PATCH,HEAD'",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    }

    depends_on = [
        aws_api_gateway_method.hourly_report_options_method,
        aws_api_gateway_integration.hourly_report_options_integration,
        aws_api_gateway_method_response.hourly_report_options_response
    ]
}

resource "aws_api_gateway_method" "hourly_report_proxy" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "hourly_report_proxy_response" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = aws_api_gateway_method.hourly_report_proxy.http_method
    status_code = "200"

    //cors section
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration" "hourly_report_lambda_integration" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = aws_api_gateway_method.hourly_report_proxy.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.get_hourly_report_lambda.invoke_arn
}


resource "aws_api_gateway_integration_response" "hourly_report_proxy_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    resource_id = aws_api_gateway_resource.hourly_report_resource.id
    http_method = aws_api_gateway_method.hourly_report_proxy.http_method
    status_code = aws_api_gateway_method_response.hourly_report_proxy_response.status_code

    //cors
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }

    depends_on = [
        aws_api_gateway_method.hourly_report_proxy,
        aws_api_gateway_integration.hourly_report_lambda_integration,
        aws_api_gateway_method_response.hourly_report_proxy_response
    ]
}

resource "aws_api_gateway_deployment" "api_deployment" {
    depends_on = [
        aws_api_gateway_integration.subscriber_lambda_integration,
        aws_api_gateway_integration.hourly_report_options_integration,
        aws_api_gateway_integration.hourly_report_lambda_integration
    ]

    rest_api_id = aws_api_gateway_rest_api.giraffe_api.id
    stage_name  = "prod"
}