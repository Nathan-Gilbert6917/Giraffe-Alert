"""
author: Nathan Gilbert
file: api_lambda_function.py
description: Lambda function to retrieve a session key and then download the
             corresponding image and then upload it to an S3 bucket
10/26/2023
"""
import os
import urllib3
import json
import boto3
import uuid

boto3.set_stream_logger('')
http = urllib3.PoolManager()


def get_session_key():
    url = "https://relay.ozolio.com/ses.api?cmd=init&oid=CID_IYVU0000014B&ver=5&channel=0&control=1&document=https%3A%2F%2Fwww.houstonzoo.org%2Fexplore%2Fwebcams%2Fgiraffe-feeding-platform%2F"

    response = http.request('GET', url)
    data_json = json.loads(response.data)

    return data_json["session"]["id"]


def download_image(session_key, key):
    image_url = f"https://relay.ozolio.com/pub.api?cmd=poster&oid={session_key}"

    # Call the API endpoint to get the image
    response = http.request('GET', image_url)
    if response.status == 200:
        # Create a temporary file in /tmp to store the image
        tmp_file_path = '/tmp/' + key

        f = open(tmp_file_path, "wb")
        f.write(response.data)
        f.close()

        return tmp_file_path


def upload_image(img_file_path, object_key):
    if img_file_path is None:
        return {'statusCode': 500, 'body': 'Image not found'}
    try:
        # Upload the image to S3
        s3 = boto3.resource('s3')
        bucket = s3.Bucket(os.environ['S3_BUCKET_NAME'])
        bucket.upload_file(img_file_path, object_key)
        # s3.upload_file(img_file_path, os.environ['S3_BUCKET_NAME'] , object_key)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: Uploading images ' + str(e)
        }


def lambda_handler(event, context):
    try:
        session_key = get_session_key()
        unique_id = str(uuid.uuid4())
        object_key = "test" + unique_id + ".jpg"
        tmp_file_path = download_image(session_key, object_key)
        # Upload the image to S3
        upload_image(tmp_file_path, object_key)
        os.remove(tmp_file_path)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: ' + str(e)
        }
    return {
        "statusCode": 200,
        "body": json.dumps("Images downloaded and uploaded to S3.")
    }
