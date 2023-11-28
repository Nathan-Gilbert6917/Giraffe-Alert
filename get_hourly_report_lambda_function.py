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
        SELECT report_id 
        FROM Reports 
        ORDER BY report_date LIMIT 1;
    """

    report_id = ""
    with connection.cursor() as cur:
        cur.execute(get_report_id_query)
        print(cur)
        report_id = cur.fetchone()[0]
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
        SELECT alert_id FROM Reports_Alerts WHERE report_id = {report_id}
    """

    alert_ids = []
    with connection.cursor() as cur:
        cur.execute(get_report_alert_ids)
        for x in cur.fetchall():
            alert_ids.append(x[0])
    connection.commit()
    
    

    get_alerts_query = f"""
        SELECT * FROM Alerts WHERE alert_id IN {tuple(alert_ids)}
    """

    alerts = []
    with connection.cursor() as cur:
        cur.execute(get_alerts_query)
        for x in cur.fetchall():
            alerts.append((x[0], x[1].strftime("%m/%d/%Y, %H:%M:%S"), x[2], x[3], x[4]))
    connection.commit()
    print(alerts)
    return alerts


def lambda_handler(event, context):
    alerts = ""
    try:
        report_id = retrieve_current_report()
        alerts = retrieve_alerts(report_id)

        return {
            'statusCode': 200,
            'body': json.dumps(alerts)
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(alerts)
        }
