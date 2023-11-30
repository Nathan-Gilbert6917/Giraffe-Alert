INSERT INTO Alerts (alert_date, giraffe_count, confidence, image_url)
    VALUES
        ('2023-11-25 08:00:00', 5, 95.5443, 'https://detected-images.s3.amazonaws.com/test3c3c106c-b8f6-4e7c-82ec-dea01c310cd1.jpg'),
        ('2023-11-25 09:30:00', 8, 92.4245, 'https://detected-images.s3.amazonaws.com/test90721dfe-30ef-4124-9a1d-88f26385b744.jpg'),
        ('2023-11-25 11:15:00', 3, 88.5456, 'https://detected-images.s3.amazonaws.com/test96cc03df-07cc-4403-98aa-bd5cf5577774.jpg'),
        ('2023-11-25 12:45:00', 6, 91.6452, 'https://detected-images.s3.amazonaws.com/testc424a3f1-f60c-4aab-9729-5de10e061be6.jpg'),
        ('2023-11-26 14:30:00', 7, 89.6453, 'https://detected-images.s3.amazonaws.com/testf28aaafa-2caa-4287-a9af-a9c9cf2a9a41.jpg'),
        ('2023-11-26 16:00:00', 2, 94.3456, 'https://detected-images.s3.amazonaws.com/test3c3c106c-b8f6-4e7c-82ec-dea01c310cd1.jpg'),
        ('2023-11-26 17:15:00', 4, 93.7556, 'https://detected-images.s3.amazonaws.com/test90721dfe-30ef-4124-9a1d-88f26385b744.jpg'),
        ('2023-11-26 19:00:00', 9, 87.5465, 'https://detected-images.s3.amazonaws.com/test96cc03df-07cc-4403-98aa-bd5cf5577774.jpg'),
        ('2023-11-27 20:45:00', 10, 86.6575, 'https://detected-images.s3.amazonaws.com/testc424a3f1-f60c-4aab-9729-5de10e061be6.jpg'),
        ('2023-11-27 22:30:00', 2, 96.6746, 'https://detected-images.s3.amazonaws.com/testf28aaafa-2caa-4287-a9af-a9c9cf2a9a41.jpg');

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