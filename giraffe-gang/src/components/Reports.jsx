import React, { useEffect, useState } from "react";
import Navbar from "./Navbar.jsx";

import "../styles/Reports.css";

function Reports() {
  const hourly_report_url = process.env.REACT_APP_ENV_API_URL+"/hourly_report"; //replace with instance url
  const isDemo = process.env.REACT_APP_ENV_DEMO;
  const [reportData, setReportData] = useState(null);

  
  useEffect(() => {
    console.log(isDemo)
    console.log(hourly_report_url)
    console.log(reportData)
    const handleHourlyReport = () => {
  
      fetch(hourly_report_url, {
          method: "GET",
          cors: true,
          headers: {
            "Content-Type": "application/json"
          }
        })
        .then((response) => response.json())
        .then((result) => {
          console.log(result);
          setReportData(result);
        })
        .catch((error) => {
          console.error(error);
        })
    };
    handleHourlyReport()
    const time = (isDemo === "true" ? 5 : 60) * 60 * 1000; //  Minutes
    const interval = setInterval(handleHourlyReport, time);
    return () => clearInterval(interval)
  }, []);
  
  return (
    <div className="reports-container">
      <h1 className="reports-heading">Reports</h1>
      {/* Add reports content here */}
      {reportData ? (
        <div>{JSON.stringify(reportData)}</div>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default Reports;
