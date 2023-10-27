# Define AWS Provider
provider "aws" {
  region = "us-east-2"  # Set your desired AWS region
}

# Define Local Variables
locals {
  image_api_bucket = "your-upload-bucket-name" # Change this to your desired upload bucket
}

# Create an S3 bucket for uploading objects
resource "aws_s3_bucket" "image_api_bucket" {
  bucket = local.image_api_bucket
  force_destroy = true
}

#### Image API Lambda Function ####

# Define the AWS Lambda function
resource "aws_lambda_function" "download_giraffe_image" {
  filename      = "api_lambda_function_payload.zip"
  function_name = "download_giraffe_image"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "api_lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = data.archive_file.image_api_lambda_code.output_base64sha256
  timeout       = 5
  # Define environment variables for the Lambda function
  environment {
    variables = {
      S3_BUCKET_NAME = "${local.image_api_bucket}"
    }
  }
}

# Create an archive of the Image API Lambda function code (ZIP file)
data "archive_file" "image_api_lambda_code" {
  type        = "zip"
  source_file  = "api_lambda_function.py"
  output_path = "api_lambda_function_payload.zip"
}

#### IAM Role for Lambda execution ####

# Define the IAM role for Lambda execution
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Define the IAM policy document
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create an IAM policy that allows PutObject (upload) permission for the S3 bucket
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Policy for Lambda to access S3 and upload files"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:PutObject",
        Effect = "Allow",
        Resource = "arn:aws:s3:::${local.image_api_bucket}/*",
      },
    ],
  })
}

# Attach the Lambda policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

#### Image API Cloud Watch Event Rule ####

# Define a CloudWatch Events rule for scheduling Lambda execution
resource "aws_cloudwatch_event_rule" "image_api_schedule" {
  name                = "lambda_schedule"
  description         = "Schedule for Lambda execution"
  schedule_expression = "rate(1 minute)"
}

# Define the target for the CloudWatch Events rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.image_api_schedule.name
  arn  = aws_lambda_function.download_giraffe_image.arn
  target_id = "download_giraffe_image"
}

# Define the permissions for the CloudWatch Events to call the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_download_giraffe_image" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.download_giraffe_image.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.image_api_schedule.arn
}