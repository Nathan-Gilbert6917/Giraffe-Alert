import boto3
import pymysql
import os

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


def preload_data():
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
    INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url)
    VALUES
        ('2023-11-09 08:00:00', 5, 95.5443, 'http://example.com/image1.jpg'),
        ('2023-11-09 09:30:00', 8, 92.4245, 'http://example.com/image2.jpg'),
        ('2023-11-09 11:15:00', 3, 88.5456, 'http://example.com/image3.jpg'),
        ('2023-11-09 12:45:00', 6, 91.6452, 'http://example.com/image4.jpg'),
        ('2023-11-09 14:30:00', 7, 89.6453, 'http://example.com/image5.jpg'),
        ('2023-11-09 16:00:00', 2, 94.3456, 'http://example.com/image6.jpg'),
        ('2023-11-09 17:15:00', 4, 93.7556, 'http://example.com/image7.jpg'),
        ('2023-11-09 19:00:00', 9, 87.5465, 'http://example.com/image8.jpg'),
        ('2023-11-09 20:45:00', 10, 86.6575, 'http://example.com/image9.jpg'),
        ('2023-11-09 22:30:00', 2, 96.6746, 'http://example.com/image10.jpg');
    """
    sql_query2 = """
    INSERT INTO Reports (report_date)
    VALUES
        ('2023-11-09 08:00:00'),
        ('2023-11-09 09:30:00'),
        ('2023-11-09 11:15:00'),
        ('2023-11-09 12:45:00'),
        ('2023-11-09 14:30:00'),
        ('2023-11-09 16:00:00'),
        ('2023-11-09 17:15:00'),
        ('2023-11-09 19:00:00'),
        ('2023-11-09 20:45:00'),
        ('2023-11-09 22:30:00');
    """
    sql_query3 = """
    INSERT INTO Reports_Alerts (report_id, alert_id)
    VALUES
        (1, 1),
        (1, 2),
        (1, 6),
        (1, 5),
        (2, 3),
        (2, 3),
        (3, 4),
        (4, 4), 
        (5, 5), 
        (6, 5); 
    """
    cursor.execute(sql_query1)
    cursor.execute(sql_query2)
    cursor.execute(sql_query3)
    connection.commit()
    # Clean up
    cursor.close()
    connection.close()


def lambda_handler(event, context):
    try:
        create_tables()
        preload_data()
    except Exception as e:
        return {
            'statusCode': 500,
            'body': 'Error: ' + str(e)
        }
    return {
        "statusCode": 200,
        "body": "SQL Queries Successful"
    }
