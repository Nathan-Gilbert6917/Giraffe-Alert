output "api_gateway_url" {
    description = "URL for gateway"
    value = aws_amplify_app.giraffe_alert_app.environment_variables.REACT_APP_ENV_API_URL
}