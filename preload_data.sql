INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url)
    VALUES
        ('2023-11-09 08:00:00', 5, 0.95, 'http://example.com/image1.jpg'),
        ('2023-11-09 09:30:00', 8, 0.92, 'http://example.com/image2.jpg'),
        ('2023-11-09 11:15:00', 3, 0.88, 'http://example.com/image3.jpg'),
        ('2023-11-09 12:45:00', 6, 0.91, 'http://example.com/image4.jpg'),
        ('2023-11-09 14:30:00', 7, 0.89, 'http://example.com/image5.jpg'),
        ('2023-11-09 16:00:00', 2, 0.94, 'http://example.com/image6.jpg'),
        ('2023-11-09 17:15:00', 4, 0.93, 'http://example.com/image7.jpg'),
        ('2023-11-09 19:00:00', 9, 0.87, 'http://example.com/image8.jpg'),
        ('2023-11-09 20:45:00', 10, 0.86, 'http://example.com/image9.jpg'),
        ('2023-11-09 22:30:00', 2, 0.96, 'http://example.com/image10.jpg');

-- Insert test data into Records table
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

-- Insert test data into Records_Alerts table
INSERT INTO Reports_Alerts (reports_id, alert_id)
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