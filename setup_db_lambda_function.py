import boto3
import pymysql
import os
import csv
from datetime import datetime
from io import StringIO

s3 = boto3.client('s3')


def create_tables():
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )
    cursor = connection.cursor()

    sql_query1 = """
    CREATE TABLE Alerts (alert_id INT AUTO_INCREMENT PRIMARY KEY,alert_date DATETIME NOT NULL,giraffe_count INT NOT NULL,confidence FLOAT NOT NULL,image_url VARCHAR(255) NOT NULL);
    """
    sql_query2 = """
    CREATE TABLE Reports (report_id INT AUTO_INCREMENT PRIMARY KEY,report_date DATETIME NOT NULL);
    """
    sql_query3 = """
    CREATE TABLE Reports_Alerts (report_alert_id INT AUTO_INCREMENT PRIMARY KEY,report_id INT, alert_id INT, FOREIGN KEY (report_id) REFERENCES Reports(report_id),FOREIGN KEY (alert_id) REFERENCES Alerts(alert_id));
    """
    cursor.execute(sql_query1)
    cursor.execute(sql_query2)
    cursor.execute(sql_query3)
    connection.commit()
    # Clean up
    cursor.close()
    connection.close()


def preload_data(alerts_data, reports_data, reports_alerts_data):
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )
    cursor = connection.cursor()

    alerts_csv = StringIO(alerts_data)
    alerts_reader = csv.reader(alerts_csv)
    next(alerts_reader)  # Skip header row
    for row in alerts_reader:
        row = row[0].split(';')
        date = row[1].split('"')
        date = datetime_object = datetime.strptime(
            date[1], '%Y-%m-%d %H:%M:%S')
        cursor.execute(
            "INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url) VALUES (%s, %s, %s, %s)",
            (date, int(row[2]), float(row[3]), row[4])
        )

    print("Reports")

    # Preload Reports data
    reports_csv = StringIO(reports_data)
    reports_reader = csv.reader(reports_csv)
    next(reports_reader)  # Skip header row
    for row in reports_reader:
        row = row[0].split(';')
        date = row[1].split('"')
        date = datetime_object = datetime.strptime(
            date[1], '%Y-%m-%d %H:%M:%S')
        cursor.execute(
            "INSERT INTO Reports (report_date) VALUES (%s)",
            (date,)
        )

    print("Reports Alerts")

    # Preload Reports_Alerts data
    reports_alerts_csv = StringIO(reports_alerts_data)
    reports_alerts_reader = csv.reader(reports_alerts_csv)
    next(reports_alerts_reader)  # Skip header row
    for row in reports_alerts_reader:
        row = row[0].split(';')
        cursor.execute(
            "INSERT INTO Reports_Alerts (report_id, alert_id) VALUES (%s, %s)",
            (int(row[1]), int(row[2]))
        )
    connection.commit()
    # Clean up
    cursor.close()
    connection.close()


def lambda_handler(event, context):
    try:
        # create_tables()

        bucket_name = 'detected-images'
        alerts_csv = 'alerts.csv'
        reports_csv = 'reports.csv'
        reports_alerts_csv = 'reports_alerts.csv'
        alerts_data = s3.get_object(Bucket=bucket_name, Key=alerts_csv).get(
            'Body').read().decode('utf-8')
        reports_data = s3.get_object(Bucket=bucket_name, Key=reports_csv).get(
            'Body').read().decode('utf-8')
        reports_alerts_data = s3.get_object(
            Bucket=bucket_name, Key=reports_alerts_csv).get('Body').read().decode('utf-8')

        preload_data(alerts_data, reports_data, reports_alerts_data)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: ' + str(e)
        }
    return {
        "statusCode": 200,
        "body": "SQL Queries Successful"
    }
