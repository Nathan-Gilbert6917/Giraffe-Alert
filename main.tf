# Define AWS Provider
provider "aws" {
  region = "us-east-2"  # Set your desired AWS region
}

# Define Local Variables
locals {
  image_api_bucket = "giraffe-upload-bucket" # Change this to your desired upload bucket
  detected_images_bucket     = "detected-images-bucket"
  rekognition_max_labels     = 15
  rekognition_min_confidence = 90
  amplify_repo               = "git@github.com:SWEN-514-614-2231/term-project-team05"
  db_schema_sql              = "giraffe_db_schema.sql" # Change this to your database schema sql file
  db_preload_data_sql        = "giraffe_db_preload_data.sql" # Change this to your database preload sql file
  db_name                    = "giraffe_db_name" # Change this to your database name
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
  environment {
    variables = {
      S3_BUCKET_NAME   = "${local.image_api_bucket}"
      SQL_SCHEMA       = "${local.db_schema_sql}"
      SQL_PRELOAD_DATA = "${local.db_preload_data_sql}"
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
  schedule_expression = "rate(1 hour)"
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

######## Frontend ########

#### Amplify Frontend ####

# Define the Amplify resources for the frontend
resource "aws_amplify_app" "giraffe_alert_app" {
  name          = "giraffe_alert_app"
  repository    = "${local.amplify_repo}" # TODO: Change to repo
}

resource "aws_amplify_branch" "amplify_branch" {
  app_id      = "${aws_amplify_app.giraffe_alert_app.id}"
  branch_name = "main"
}

