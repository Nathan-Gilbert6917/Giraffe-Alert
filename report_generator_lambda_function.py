import boto3
import pymysql
import os

s3 = boto3.client('s3')


def connect_db():
    # MySQL connection
    connection = pymysql.connect(
        host=os.environ['DB_HOST'].split(":")[0],
        user=os.environ['DB_USER'],
        passwd=os.environ['DB_PASSWORD'],
        db=os.environ['DB_NAME'],
        connect_timeout=5
    )

    return connection


def generate_report(connection):
    with connection.cursor() as cur:
        # Create a Report
        insert_report_query = """
            INSERT INTO Reports (report_date)
            VALUES (NOW());
        """
        cur.execute(insert_report_query)

        # Get the latest report for the id
        cur.execute("SELECT LAST_INSERT_ID();")
        report_id = cur.fetchone()[0]
        connection.commit()
        return report_id


def generate_report_alerts(connection, report_id):
    with connection.cursor() as cur:
        # Get all alerts from the past 3 days
        past_3days_alert_ssql_query = """
            SELECT * 
            FROM Alerts 
            WHERE alert_date >= DATE_SUB(NOW(), INTERVAL 3 DAY);
        """

        cur.execute(past_3days_alert_ssql_query)
        connection.commit()
        alerts = cur.fetchall()

        for alert in alerts:
            insert_reports_alerts_query = f"""
                INSERT INTO Reports_Alerts (report_id, alert_id)
                VALUES ({report_id}, {alert[0]});
            """
            cur.execute(insert_reports_alerts_query)
        connection.commit()


def cleanup_db(connection):
    # Clean up
    connection.close()


def lambda_handler(event, context):
    try:
        db_conn = connect_db()
        report_id = generate_report(db_conn)
        generate_report_alerts(db_conn, report_id)
        cleanup_db(db_conn)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: ' + str(e)
        }
    return {
        "statusCode": 200,
        "body": json.dumps("SQL Queries Successful")
    }
