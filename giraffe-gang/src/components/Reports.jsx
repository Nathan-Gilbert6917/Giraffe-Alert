import React, { useEffect, useState } from "react";
import { Flex } from "antd";

import "../styles/Reports.css";

function Reports() {
  const hourly_report_url =
    process.env.REACT_APP_ENV_API_URL + "/hourly_report"; //replace with instance url
  const isDemo = process.env.REACT_APP_ENV_DEMO;
  const [reportData, setReportData] = useState(null);
  const [reportDate, setReportDate] = useState("");
  const [reportSummaryData, setReportSummaryData] = useState({});

  const generateSummaryData = (reportData) => {
    let giraffe_count = 0;
    let confidences = [];

    JSON.parse(reportData).map((alert) => {
      giraffe_count += alert[2];
      confidences.push(alert[3]);
    });

    let confidence_sum = confidences.reduce(
      (acc, confidence) => acc + confidence,
      0
    );
    const average_confidence = confidence_sum / confidences.length;

    let average = Math.round(average_confidence * 100) / 100;

    if (isNaN(average)) {
      average = "Cannot calculate confidence";
    } else {
      average = average + "%";
    }

    return {
      alerts_count: confidences.length,
      giraffe_count: giraffe_count,
      average_confidence: average,
    };
  };

  const normalizeData = (data) =>
    Object.keys(data).map((key) => ({
      id: key,
    }));

  useEffect(() => {
    console.log(isDemo);
    const handleHourlyReport = () => {
      fetch(hourly_report_url, {
        method: "GET",
        cors: true,
        headers: {
          "Content-Type": "application/json",
        },
      })
        .then((response) => response.json())
        .then((result) => {
          setReportData(result.body.alerts);
          setReportDate(result.body.report_date);
          const summaryData = generateSummaryData(result.body.alerts);
          setReportSummaryData(summaryData);
        })
        .catch((error) => {
          console.error(error);
        });
    };
    handleHourlyReport();
    const time = (isDemo === "true" ? 5 : 60) * 60 * 1000; //  Minutes
    const interval = setInterval(handleHourlyReport, time);
    return () => clearInterval(interval);
  }, [reportData, reportSummaryData, reportSummaryData]);

  return (
    <div className="reports-container">
      <h1 className="reports-heading">Report {reportDate}</h1>
      {/* Add reports content here */}
      {reportData ? (
        <div>
          <div>
            <h2>Report Summary</h2>
            <h3>Total Alerts: {reportSummaryData["alerts_count"]}</h3>
            <h3>Total Giraffes: {reportSummaryData["giraffe_count"]}</h3>
            <h3>
              Average Confidence: {reportSummaryData["average_confidence"]}
            </h3>
          </div>
          <Flex gap="middle" vertical>
            <Flex gap="middle" horizontal>
              <div
                style={{
                  backgroundColor: "#DED0B6",
                  width: "25%",
                  padding: "1%",
                }}
              >
                <b>ID</b>
              </div>
              <div
                style={{
                  backgroundColor: "#DED0B6",
                  width: "25%",
                  padding: "1%",
                }}
              >
                <b>Date</b>
              </div>
              <div
                style={{
                  backgroundColor: "#DED0B6",
                  width: "25%",
                  padding: "1%",
                }}
              >
                <b>Giraffes</b>
              </div>
              <div
                style={{
                  backgroundColor: "#DED0B6",
                  width: "25%",
                  padding: "1%",
                }}
              >
                <b>Confidence</b>
              </div>
              <div
                style={{
                  backgroundColor: "#DED0B6",
                  width: "25%",
                  padding: "1%",
                }}
              >
                <b>Link</b>
              </div>
            </Flex>
            {JSON.parse(reportData).map((item, index) => {
              return (
                <Flex gap="middle" horizontal>
                  <div
                    key={index}
                    style={{
                      backgroundColor: index % 2 ? "#DED0B6" : "#FAEED1",
                      width: "20%",
                      padding: "1%",
                    }}
                  >
                    {item[0]}
                  </div>
                  <div
                    key={index}
                    style={{
                      backgroundColor: index % 2 ? "#DED0B6" : "#FAEED1",
                      width: "20%",
                      padding: "1%",
                    }}
                  >
                    {item[1]}
                  </div>
                  <div
                    key={index}
                    style={{
                      backgroundColor: index % 2 ? "#DED0B6" : "#FAEED1",
                      width: "20%",
                      padding: "1%",
                    }}
                  >
                    {item[2]}
                  </div>
                  <div
                    key={index}
                    style={{
                      backgroundColor: index % 2 ? "#DED0B6" : "#FAEED1",
                      width: "20%",
                      padding: "1%",
                    }}
                  >
                    {Math.round(item[3] * 100) / 100}%
                  </div>
                  <div
                    key={index}
                    style={{
                      backgroundColor: index % 2 ? "#DED0B6" : "#FAEED1",
                      width: "20%",
                      padding: "1%",
                    }}
                  >
                    <a href={item[4]} target="_blank">
                      Image Link
                    </a>
                  </div>
                </Flex>
              );
            })}
          </Flex>
        </div>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default Reports;
