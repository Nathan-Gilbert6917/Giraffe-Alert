"""
author: Nathan Gilbert
file: rekognition_lambda_function.py
description: Lambda function triggered by S3 bucket object creation and detects if the image contains a giraffe.
If a giraffe is detected the function will send an email notification to the SNS to alert subscribers.
11/3/2023
"""
import os
import json
import pymysql
import boto3
from datetime import datetime

# Initialize the AWS clients
s3_client = boto3.client('s3')
rekognition_client = boto3.client('rekognition')
sns_client = boto3.client('sns')

# S3 bucket for detected images
detected_images_bucket = os.environ['S3_BUCKET_NAME']


def insert_alert(alert_data):
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )

    alert_date = alert_data['alert_date']
    giraffe_count = alert_data['giraffe_count']
    confidence = alert_data['confidence']
    image_url = alert_data['image_url']

    insert_alert_query = f"""
        INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url)
        VALUES ('{alert_date}', {giraffe_count}, {confidence}, '{image_url}')
    """

    with connection.cursor() as cur:
        cur.execute(insert_alert_query)
    connection.commit()


def lambda_handler(event, context):
    try:
        # Get the S3 bucket and object key from the event
        s3_bucket = event['Records'][0]['s3']['bucket']['name']
        s3_object_key = event['Records'][0]['s3']['object']['key']

        # Use Rekognition to detect giraffes in the image
        print(s3_bucket, s3_object_key)
        response = rekognition_client.detect_labels(
            Image={
                'S3Object': {
                    'Bucket': s3_bucket,
                    'Name': s3_object_key
                }
            },
            MaxLabels=int(os.environ['MAX_LABELS']),
            # Adjust this confidence level as needed
            MinConfidence=int(os.environ['MIN_CONFIDENCE'])
        )

        # Check if giraffe label is in the detected labels
        is_giraffe = False
        giraffe_confidence = 0
        giraffe_count = 0
        for label in response['Labels']:
            if label['Name'] == 'Giraffe':
                is_giraffe = True
                giraffe_confidence = label['Confidence']
                giraffe_count = len(label['Instances'])
                break

        if is_giraffe:
            # Upload the image to the detected images bucket by copying image
            new_object_key = f'detected/{s3_object_key}'
            s3_client.copy_object(
                CopySource={'Bucket': s3_bucket, 'Key': s3_object_key},
                Bucket=detected_images_bucket,
                Key=new_object_key
            )

            # Get the public URL of the detected image
            detected_image_url = f'https://{detected_images_bucket}.s3.amazonaws.com/{new_object_key}'

            # Generate an email with the detected image link
            email_message = f'Detected {giraffe_count} Giraffe!\n\nWe have a confidence rating of {giraffe_confidence}\nView Image That Generated Alert: {detected_image_url}'

            # Publish the email alert to an SNS topic
            sns_topic_arn = os.environ['SNS_TOPIC_ARN']
            sns_client.publish(
                TopicArn=sns_topic_arn,
                Message=email_message,
                Subject="Giraffe Alert!"
            )

            current_datetime = datetime.now()

            # Format the datetime in a way SQL understands (YYYY-MM-DD HH:MM:SS)
            sql_formatted_datetime = current_datetime.strftime(
                '%Y-%m-%d %H:%M:%S'
            )

            alert_data = {
                'alert_date': sql_formatted_datetime,
                'giraffe_count': giraffe_count,
                'confidence': giraffe_confidence,
                'image_url': detected_image_url
            }
            insert_alert(alert_data)

        else:
            print("No giraffe detected in the image.")

        return {
            'statusCode': 200,
            'body': json.dumps('Lambda executed successfully.')
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps('Lambda execution failed.')
        }
