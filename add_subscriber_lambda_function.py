import boto3
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    try:
        # Extract SNS Topic ARN from environment variable
        topic_arn = os.getenv('SNS_TOPIC_ARN')
        if not topic_arn:
            raise ValueError("SNS_TOPIC_ARN environment variable is not set")

        logger.info(event)
        # subscriber email from event body
        subscriber = json.loads(event.get('body')).get('email')
        if not subscriber:
            raise ValueError("Email is missing from event data", event)

        sns = boto3.client('sns')

        # Attempt to subscribe the user
        response = sns.subscribe(
            TopicArn=topic_arn,
            Protocol='email',
            Endpoint=subscriber
        )

        # Log successful subscription
        logger.info(
            f"Subscriber {subscriber} added successfully to topic {topic_arn}")

        return {
            'statusCode': 200,
            'body': json.dumps('Subscriber added successfully to Giraffe Alert.')
        }

    except Exception as e:
        # Log the error
        logger.error(f"Error in Lambda function: {str(e)}")

        return {
            'statusCode': 500,
            'body': json.dumps(f"Error adding subscriber: {str(e)}")
        }
