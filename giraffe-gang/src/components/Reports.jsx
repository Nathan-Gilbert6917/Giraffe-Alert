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
          mode: "no-cors",
          headers: {
            "Content-Type": "application/json",
          }
        })
        .then((response) => {
          console.log("Response: " +response);
          if (response.ok) {
            const data = response;
            console.log(data);
            setReportData(data);
          } else {
            const data = response;
            console.log(data);
            setReportData(data);
            console.error("Failed to subscribe:", response.statusText);
          }
        })
        .catch((error) => {
          console.log(error);
          setReportData(error);
          console.error("Error:", error);
        });
    };
    handleHourlyReport()
    const time = (isDemo === "true" ? 5 : 60) * 60 * 1000; //  Minutes
    const interval = setInterval(handleHourlyReport, time);
    return () => clearInterval(interval)
  }, []);
  
  return (
    <div className="reports-container">
      <Navbar />

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
