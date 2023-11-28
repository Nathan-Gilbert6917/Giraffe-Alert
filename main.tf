# Define AWS Provider
provider "aws" {
  region = "us-east-2"  # Set your desired AWS region
}

# Define Local Variables
locals {
  terraform_deploy_bucket    = "giraffe-terra-test" # Change this to the name of the bucket you are using to deploy terraform
  image_api_bucket           = "giraffe-upload" # Change this to your desired upload bucket
  detected_images_bucket     = "detected-images"
  rekognition_max_labels     = 15
  rekognition_min_confidence = 90
  amplify_repo               = "https://github.com:SWEN-514-614-2231/term-project-team05"
  github_access_token        = "" # Change this to your desired github access token
  db_schema_sql              = "giraffe_db_schema.sql" 
  db_preload_data_sql        = "giraffe_db_preload_data.sql"
  db_name                    = "giraffe_db" 
  db_username                = "giraffe_db_user" # Change this to your desired database username
  db_password                = "muchsecurity" # Change this to a better password
}

######## User Notification ########

#### SNS ####

# Define SNS topic for subscribed users to get email giraffe alert notifications
resource "aws_sns_topic" "giraffe_alert" {
  name = "subscribed-giraffe-alert"
}

######## Storage ########

#### S3 Buckets ####

# Define an S3 bucket for uploading images from API
resource "aws_s3_bucket" "image_api_bucket" {
  bucket        = local.image_api_bucket
  force_destroy = true
}

# Define an S3 bucket for uploading images with Giraffes detected
resource "aws_s3_bucket" "detected_images_bucket" {
  bucket        = local.detected_images_bucket
  force_destroy = true
}

# Define S3 public access block to prevent policy blocks allowing for public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "example" {
  depends_on = [aws_s3_bucket.detected_images_bucket]
  bucket = aws_s3_bucket.detected_images_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Define policy for detected images s3 bucket for public read access
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  depends_on = [ aws_s3_bucket_public_access_block.example ]
  bucket = aws_s3_bucket.detected_images_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${local.detected_images_bucket}/*",
      },
    ],
  })
}

#### RDS Database ####

# Define a RDS database to hold alerts and reports
resource "aws_db_instance" "main_db_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t2.micro"
  db_name                = "${local.db_name}"
  username               = "${local.db_username}"
  password               = "${local.db_password}"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.sg.id]
}

# Create a security group within the VPC that allows for open connetions in and out
resource "aws_security_group" "sg" {
  name = "sg"
  description = "Open security group"

  # Allow all inbound traffic
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define trigger for Lambda on Terraform Load
resource "terraform_data" "trigger_lambda" {
  depends_on = [aws_lambda_function.apply_sql_lambda, aws_db_instance.main_db_instance]
  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${aws_lambda_function.apply_sql_lambda.function_name} /dev/null"
  }
}

######## Lambda Functions ########

#### SQL applier Lambda Function ####
resource "aws_lambda_function" "apply_sql_lambda" {
  depends_on = [aws_db_instance.main_db_instance]
  filename      = "apply_sql_lambda_payload.zip"
  function_name = "apply_sql_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "setup_db_lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = data.archive_file.apply_sql_lambda_code.output_base64sha256
  layers = [aws_lambda_layer_version.python38-pymysql-layer.arn]

  environment {
    variables = {
      DB_HOST          = "${aws_db_instance.main_db_instance.endpoint}"
      DB_USER          = "${local.db_username}"
      DB_PASSWORD      = "${local.db_password}"
      DB_NAME          = "${local.db_name}"
    }
  }
}

#### SNS Topic subscriber lamba function ####

resource "aws_lambda_function" "add_subscriber_to_giraffe_alert" {
  filename         = "add_subscriber_to_giraffe_alert_payload.zip"
  function_name    = "add_subscriber_to_giraffe_alert"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "add_subscriber_lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.add_subscriber_lambda_code.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.giraffe_alert.arn
    }
  }
}

#### Get Hourly Report lamba function ####

resource "aws_lambda_function" "get_hourly_report_lambda" {
  filename         = "get_hourly_report_lambda_payload.zip"
  function_name    = "get_hourly_report_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "get_hourly_report_lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.get_hourly_report_lambda_code.output_base64sha256
  layers = [aws_lambda_layer_version.python38-pymysql-layer.arn]

  environment {
    variables = {
      DB_HOST          = "${aws_db_instance.main_db_instance.endpoint}"
      DB_USER          = "${local.db_username}"
      DB_PASSWORD      = "${local.db_password}"
      DB_NAME          = "${local.db_name}"
    }
  }
}

#### Image API Lambda Function ####

# Define the AWS Lambda function
resource "aws_lambda_function" "download_giraffe_image" {
  filename         = "api_lambda_function_payload.zip"
  function_name    = "download_giraffe_image"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "api_lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.image_api_lambda_code.output_base64sha256
  timeout          = 5
  # Define environment variables for the Lambda function
  environment {
    variables = {
      S3_BUCKET_NAME   = "${local.image_api_bucket}"
    }
  }
}

#### Rekognition Lambda Function ####

# Define the AWS Lambda function
resource "aws_lambda_function" "rekognition_handler" {
  filename      = "rekognition_lambda_function_payload.zip"
  function_name = "rekognition_handler"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "rekognition_lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = data.archive_file.rekognition_lambda_code.output_base64sha256
  timeout       = 5
  layers = [aws_lambda_layer_version.python38-pymysql-layer.arn]

  # Define environment variables for the Lambda function
  environment {
    variables = {
      S3_BUCKET_NAME = "${local.detected_images_bucket}"
      SNS_TOPIC_ARN = aws_sns_topic.giraffe_alert.arn
      MAX_LABELS = "${local.rekognition_max_labels}"
      MIN_CONFIDENCE = "${local.rekognition_min_confidence}"
      DB_HOST     = "${aws_db_instance.main_db_instance.endpoint}"
      DB_USER     = "${local.db_username}"
      DB_PASSWORD = "${local.db_password}"
      DB_NAME     = "${local.db_name}"
    }
  }
}

#### Report Generator Lambda Function ####

# Define the AWS Lambda function
resource "aws_lambda_function" "report_generator" {
  filename      = "report_generator_lambda_function_payload.zip"
  function_name = "report_generator"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "report_generator_lambda_function.lambda_handler"
  runtime       = "python3.8"
  source_code_hash = data.archive_file.report_generator_lambda_code.output_base64sha256
  timeout       = 5
  layers = [aws_lambda_layer_version.python38-pymysql-layer.arn]

  # Define environment variables for the Lambda function
  environment {
    variables = {
      DB_HOST     = "${aws_db_instance.main_db_instance.endpoint}"
      DB_USER     = "${local.db_username}"
      DB_PASSWORD = "${local.db_password}"
      DB_NAME     = "${local.db_name}"
    }
  }
}

#### Archive Files for the AWS Lambda functions code ####

# Define an archive of the Setup DB_HOST Lambda function code (ZIP file)
data "archive_file" "apply_sql_lambda_code" {
  type         = "zip"
  source_file  = "setup_db_lambda_function.py"
  output_path  = "apply_sql_lambda_payload.zip"
}

# Define an archive of the Image API Lambda function code (ZIP file)
data "archive_file" "image_api_lambda_code" {
  type        = "zip"
  source_file  = "api_lambda_function.py"
  output_path = "api_lambda_function_payload.zip"
}

# Define an archive of the Rekognition Lambda function code (ZIP file)
data "archive_file" "rekognition_lambda_code" {
  type        = "zip"
  source_file  = "rekognition_lambda_function.py"
  output_path = "rekognition_lambda_function_payload.zip"
}

# Define an archive of the Report Generator Lambda function code (ZIP file)
data "archive_file" "report_generator_lambda_code" {
  type        = "zip"
  source_file  = "report_generator_lambda_function.py"
  output_path = "report_generator_lambda_function_payload.zip"
}

# Define an archive of the PyMySQL package (ZIP file)
resource "aws_lambda_layer_version" "python38-pymysql-layer" {
    filename            = "layers/python_pymysql.zip"
    layer_name          = "python_pymysql"
    source_code_hash    = "${filebase64sha256("layers/python_pymysql.zip")}"
    compatible_runtimes = ["python3.8"]
}

# Define an archive of the SNS topic Subscriber Lambda function code (ZIP file)

data "archive_file" "add_subscriber_lambda_code" {
  type        = "zip"
  source_file = "add_subscriber_lambda_function.py"
  output_path = "add_subscriber_to_giraffe_alert_payload.zip"
}

# Define an archive of the API get for hourly report Lambda function code (ZIP file)

data "archive_file" "get_hourly_report_lambda_code" {
  type        = "zip"
  source_file = "get_hourly_report_lambda_function.py"
  output_path = "get_hourly_report_lambda_payload.zip"
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

# Define an IAM policy that allows PutObject (upload) permission for the S3 bucket
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Policy for Lambda to access S3 and upload files"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:PutObject", "s3:GetObject", "s3:CopyObject"],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${local.image_api_bucket}",
          "arn:aws:s3:::${local.image_api_bucket}/*",
          "arn:aws:s3:::${local.detected_images_bucket}",
          "arn:aws:s3:::${local.detected_images_bucket}/*",
        ]
      },
      {
        Action = ["rekognition:DetectLabels", "SNS:Publish"],
        Effect = "Allow",
        Resource = "*",
      },
    ],
  })
}

# Define an IAM policy that allows to subscribe to topic through lambda
resource "aws_iam_policy" "lambda_sns_subscribe_policy" {
  name        = "lambda_sns_subscribe_policy"
  description = "IAM policy for Lambda function to subscribe to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "SNS:Subscribe",
        Resource = aws_sns_topic.giraffe_alert.arn
      }
    ],
  })
}

#### Lambda Policy Attachment ####

# Define attachment for S3 put permission to lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# Define attachment for CloudWatch Log permission to lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs" {
  depends_on = [aws_iam_role_policy_attachment.lambda_s3_policy_attachment]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "rekognition_lambda_full_access_policy_attachment" {
  depends_on = [aws_iam_role_policy_attachment.lambda_cloudwatch_logs]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
  role       = aws_iam_role.iam_for_lambda.name
}

# Define attachment for lambda for subscribe iam
resource "aws_iam_role_policy_attachment" "lambda_sns_subscribe_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_sns_subscribe_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}


######## Lambda Function Triggers ########

#### Image API Cloud Watch Event Rule ####

# Define a CloudWatch Events rule for scheduling Lambda execution
resource "aws_cloudwatch_event_rule" "image_api_schedule" {
  name                = "image_api_schedule"
  description         = "Schedule for Lambda execution"
  schedule_expression = "rate(1 minute)"
}

# Define the target for the CloudWatch Events rule (the Image API Lambda function)
resource "aws_cloudwatch_event_target" "image_api_target" {
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

#### Hourly Report Cloud Watch Event Rule ####

# Define a CloudWatch Events rule for scheduling the Report Generator Lambda execution (hourly)
resource "aws_cloudwatch_event_rule" "hourly_report_schedule" {
  name                = "hourly_report_schedule"
  description         = "Hourly schedule for Report Generator Lambda"
  schedule_expression = "rate(5 minutes)"
}

# Define the target for the CloudWatch Events rule (the Report Generator Lambda function)
resource "aws_cloudwatch_event_target" "report_generator_target" {
  rule = aws_cloudwatch_event_rule.hourly_report_schedule.name
  arn  = aws_lambda_function.report_generator.arn
  target_id = "report_generator"
}

# Define the permissions for the CloudWatch Events to call the Report Generator Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_report_generator" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.report_generator.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.hourly_report_schedule.arn
}

#### S3 Event Rule to Trigger Rekognition Lambda ####

# Define an S3 event trigger for the Rekognition Lambda function
resource "aws_s3_bucket_notification" "rekognition_trigger" {
  bucket = "${aws_s3_bucket.image_api_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.rekognition_handler.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

# Define permission for S3 to invoke the Rekognition Lambda function
resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rekognition_handler.function_name}"
  principal = "s3.amazonaws.com"
  source_arn = "arn:aws:s3:::${aws_s3_bucket.image_api_bucket.id}"
}

#### S3 Event Rule to Trigger Subscriber Lambda ####

# Define permission for S3 to invoke the Subscriber Lambda function
resource "aws_lambda_permission" "allow_subscriber_api_to_invoke_lambda" {
  statement_id  = "AllowSubscriberAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_subscriber_to_giraffe_alert.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.giraffe_rest_api.execution_arn}/*/*"
}

#### S3 Event Rule to Trigger Frontend Hourly Report Lambda ####

# Define permission for S3 to invoke the Frontend Hourly Report Lambda function
resource "aws_lambda_permission" "allow_hourly_report_api_to_invoke_lambda" {
  statement_id  = "AllowSubscriberAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_hourly_report_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.giraffe_rest_api.execution_arn}/*/*"
}

#### API Gateway ####

resource "aws_api_gateway_rest_api" "giraffe_rest_api" {
  name        = "GiraffeAPI"
  description = "API for managing Giraffe App"
}

resource "aws_api_gateway_resource" "subscriber_endpoint" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  parent_id   = aws_api_gateway_rest_api.giraffe_rest_api.root_resource_id
  path_part   = "subscriber"
}

resource "aws_api_gateway_method" "subscriber_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id   = aws_api_gateway_resource.subscriber_endpoint.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "subscriber_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id = aws_api_gateway_resource.subscriber_endpoint.id
  http_method = aws_api_gateway_method.subscriber_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_subscriber_to_giraffe_alert.invoke_arn
}

## Hourly Report ##

resource "aws_api_gateway_resource" "hourly_report_endpoint" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  parent_id   = aws_api_gateway_rest_api.giraffe_rest_api.root_resource_id
  path_part   = "hourly_report"
}

resource "aws_api_gateway_method" "hourly_report_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id   = aws_api_gateway_resource.hourly_report_endpoint.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hourly_report_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id = aws_api_gateway_resource.hourly_report_endpoint.id
  http_method = aws_api_gateway_method.hourly_report_post_method.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_hourly_report_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.subscriber_lambda_integration,
    aws_api_gateway_integration.hourly_report_lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  stage_name  = "dev"
}

#### CORS ####

# Add OPTIONS method to handle CORS preflight requests
resource "aws_api_gateway_method" "subscriber_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id   = aws_api_gateway_resource.subscriber_endpoint.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Add a Mock Integration to return the CORS headers
resource "aws_api_gateway_integration" "subscriber_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id = aws_api_gateway_resource.subscriber_endpoint.id
  http_method = aws_api_gateway_method.subscriber_options_method.http_method

  type                    = "MOCK"
  request_templates       = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Define the response for OPTIONS method
resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id = aws_api_gateway_resource.subscriber_endpoint.id
  http_method = aws_api_gateway_method.subscriber_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Define the integration response to include CORS headers
resource "aws_api_gateway_integration_response" "cors_integration_response" {
  depends_on = [
    aws_api_gateway_integration.subscriber_options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.giraffe_rest_api.id
  resource_id = aws_api_gateway_resource.subscriber_endpoint.id
  http_method = aws_api_gateway_method.subscriber_options_method.http_method
  status_code = aws_api_gateway_method_response.cors_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}


######## Frontend ########

#### Amplify Frontend ####

# Define the Amplify resources for the frontend
resource "aws_amplify_app" "giraffe_alert_app" {
  depends_on = [ aws_api_gateway_deployment.api_deployment ]
  name          = "giraffe_alert_app"
  repository    = "${local.amplify_repo}"
  access_token = "${local.github_access_token}"
  enable_auto_branch_creation = true

  # The default patterns added by the Amplify Console.
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]

  auto_branch_creation_config {
    # Enable auto build for the created branch.
    enable_auto_build = true
  }

  environment_variables = {
    REACT_APP_ENV_API_URL = "${aws_api_gateway_deployment.api_deployment.invoke_url}"  
  }
}

resource "aws_amplify_branch" "amplify_branch" {
  app_id      = "${aws_amplify_app.giraffe_alert_app.id}"
  branch_name = "main"
}
