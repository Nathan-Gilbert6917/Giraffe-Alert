CREATE SCHEMA giraffe_db;

CREATE TABLE giraffe_db.Alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    alert_date DATETIME NOT NULL,
    giraffe_count INT NOT NULL,
    confidence FLOAT NOT NULL,
    image_url VARCHAR(255) NOT NULL
);

CREATE TABLE giraffe_db.Report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    report_date DATETIME NOT NULL
);

CREATE TABLE giraffe_db.Reports_Alerts (
    report_alert_id INT AUTO_INCREMENT PRIMARY KEY,
    report_id INT,
    alert_id INT,
    FOREIGN KEY (report_id) REFERENCES Reports(report_id),
    FOREIGN KEY (alert_id) REFERENCES Alerts(alert_id)
);
