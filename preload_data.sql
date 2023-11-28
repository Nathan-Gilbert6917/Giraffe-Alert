INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url)
    VALUES
        ('2023-11-25 08:00:00', 5, 95.5443, 'http://example.com/image1.jpg'),
        ('2023-11-25 09:30:00', 8, 92.4245, 'http://example.com/image2.jpg'),
        ('2023-11-25 11:15:00', 3, 88.5456, 'http://example.com/image3.jpg'),
        ('2023-11-25 12:45:00', 6, 91.6452, 'http://example.com/image4.jpg'),
        ('2023-11-26 14:30:00', 7, 89.6453, 'http://example.com/image5.jpg'),
        ('2023-11-26 16:00:00', 2, 94.3456, 'http://example.com/image6.jpg'),
        ('2023-11-26 17:15:00', 4, 93.7556, 'http://example.com/image7.jpg'),
        ('2023-11-26 19:00:00', 9, 87.5465, 'http://example.com/image8.jpg'),
        ('2023-11-27 20:45:00', 10, 86.6575, 'http://example.com/image9.jpg'),
        ('2023-11-27 22:30:00', 2, 96.6746, 'http://example.com/image10.jpg');

-- Insert test data into Records table
INSERT INTO Reports (report_date)
VALUES
    ('2023-11-25 08:00:00'),
    ('2023-11-25 09:30:00'),
    ('2023-11-25 11:15:00'),
    ('2023-11-25 12:45:00'),
    ('2023-11-26 14:30:00'),
    ('2023-11-26 16:00:00'),
    ('2023-11-26 17:15:00'),
    ('2023-11-26 19:00:00'),
    ('2023-11-27 20:45:00'),
    ('2023-11-27 22:30:00');

-- Insert test data into Records_Alerts table
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