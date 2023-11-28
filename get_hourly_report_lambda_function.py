"""
author: Nathan Gilbert
file: get_hourly_report_lambda_function.py
description: Lambda function triggered by API endpoint returns the alerts related to a report.
11/27/2023
"""
import os
import json
import pymysql
import boto3
from datetime import datetime

# Initialize the AWS clients
s3_client = boto3.client('s3')


def retrieve_current_report():
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )

    get_report_id_query = """
        SELECT record_id 
        FROM Records 
        ORDER BY record_date LIMIT 1;
    """

    report_id = ""
    with connection.cursor() as cur:
        cur.execute(get_report_id_query)
        report_id = cur[0]
    connection.commit()
    
    return report_id

def retrieve_alerts(report_id):
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )

    get_report_alert_ids = f"""
        GET alert_id FROM Reports_Alerts WHERE report_id = {report_id}
    """

    alert_ids = ""
    with connection.cursor() as cur:
        cur.execute(get_report_alert_ids)
        alert_ids = cur
    connection.commit()

    get_alerts_query = f"""
        GET * FROM Alerts WHERE alert_id in {alert_ids}
    """

    alerts = ""
    with connection.cursor() as cur:
        cur.execute(get_alerts_query)
        alerts = cur
    connection.commit()

    return alerts


def lambda_handler(event, context):
    try:
        report_id = retrieve_current_report()
        alerts = retrieve_alerts(report_id)

        return {
            'statusCode': 200,
            'body': {
                'alerts': alerts,
                'execution':json.dumps('Lambda executed successfully.')
            }
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'alerts': alerts,
            'body': {
                'alerts': alerts,
                'execution': json.dumps('Lambda execution failed.')
            }
        }
