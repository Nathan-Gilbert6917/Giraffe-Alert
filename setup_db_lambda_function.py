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
        ('2023-12-05 08:00:00', 1, 95.5443, 'https://detected-images.s3.amazonaws.com/test3c3c106c-b8f6-4e7c-82ec-dea01c310cd1.jpg'),
        ('2023-12-05 09:30:00', 2, 92.4245, 'https://detected-images.s3.amazonaws.com/test90721dfe-30ef-4124-9a1d-88f26385b744.jpg'),
        ('2023-12-06 11:15:00', 1, 88.5456, 'https://detected-images.s3.amazonaws.com/test96cc03df-07cc-4403-98aa-bd5cf5577774.jpg'),
        ('2023-12-06 12:45:00', 1, 91.6452, 'https://detected-images.s3.amazonaws.com/testc424a3f1-f60c-4aab-9729-5de10e061be6.jpg'),
        ('2023-12-07 14:30:00', 1, 89.6453, 'https://detected-images.s3.amazonaws.com/testf28aaafa-2caa-4287-a9af-a9c9cf2a9a41.jpg'),
        ('2023-12-07 16:00:00', 1, 94.3456, 'https://detected-images.s3.amazonaws.com/test3c3c106c-b8f6-4e7c-82ec-dea01c310cd1.jpg'),
        ('2023-12-07 17:15:00', 2, 93.7556, 'https://detected-images.s3.amazonaws.com/test90721dfe-30ef-4124-9a1d-88f26385b744.jpg'),
        ('2023-12-07 19:00:00', 1, 87.5465, 'https://detected-images.s3.amazonaws.com/test96cc03df-07cc-4403-98aa-bd5cf5577774.jpg'),
        ('2023-12-08 09:30:00', 1, 86.6575, 'https://detected-images.s3.amazonaws.com/testc424a3f1-f60c-4aab-9729-5de10e061be6.jpg'),
        ('2023-12-08 10:30:00', 1, 96.6746, 'https://detected-images.s3.amazonaws.com/testf28aaafa-2caa-4287-a9af-a9c9cf2a9a41.jpg');
    """
    sql_query2 = """
    INSERT INTO Reports (report_date)
    VALUES
        ('2023-12-05 08:00:00'),
        ('2023-12-05 09:30:00'),
        ('2023-12-06 11:15:00'),
        ('2023-12-06 12:45:00'),
        ('2023-12-07 14:30:00'),
        ('2023-12-07 16:00:00'),
        ('2023-12-07 17:15:00'),
        ('2023-12-07 19:00:00'),
        ('2023-12-08 09:45:00'),
        ('2023-12-08 10:30:00');
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
