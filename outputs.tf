output "api_gateway_url" {
    description = "URL for gateway"
    value = aws_amplify_app.giraffe_alert_app.environment_variables.subscribe_api_url
}