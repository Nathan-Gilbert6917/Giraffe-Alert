import boto3
import pymysql
import os
import tempfile
import shutil

s3 = boto3.client('s3')


def apply_sql(filename):
    # Retrieve SQL file from S3 bucket
    bucket_name = os.environ['S3_BUCKET_NAME']
    key = filename

    # Temporary directory to store SQL file
    temp_dir = tempfile.mkdtemp()
    file_path = os.path.join(temp_dir, 'temp.sql')

    # Download SQL file from S3
    s3.download_file(bucket_name, key, file_path)

    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )
    cursor = connection.cursor()

    # Apply SQL file to the database
    with open(file_path, 'r') as sql_file:
        sql_query = sql_file.read()
        cursor.execute(sql_query)
        connection.commit()

    # Clean up
    cursor.close()
    connection.close()
    shutil.rmtree(temp_dir)


def lambda_handler(event, context):
    try:
        schema_filename = os.environ['SQL_SCHEMA']
        preload_data_filename = os.environ['SQL_PRELOAD_DATA']

        apply_sql(schema_filename)
        apply_sql(preload_data_filename)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: ' + str(e)
        }
    return {
        "statusCode": 200,
        "body": json.dumps("SQL Queries Successful")
    }
