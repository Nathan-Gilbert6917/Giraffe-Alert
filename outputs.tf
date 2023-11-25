output "api_gateway_url" {
    description = "URL of the API Gateway"
    value = aws_api_gateway_deployment.subscriber_api_deployment.invoke_url
}

output "api_gateway_bucket" {
    description = "Bucket to store the URL of the API Gateway"
    value = aws_s3_bucket.gateway_api_bucket.bucket
}