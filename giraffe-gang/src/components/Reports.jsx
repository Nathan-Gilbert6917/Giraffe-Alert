import React, { useEffect, useState } from "react";
import Navbar from "./Navbar.jsx";
import "../styles/Reports.css";

function Reports() {
  const hourly_report_url = process.env.REACT_APP_ENV_API_URL+"/hourly_report"; //replace with instance url
  const isDemo = process.env.REACT_APP_ENV_DEMO;
  const [reportData, setReportData] = useState(null);

  console.log(isDemo)
  console.log(hourly_report_url)
  console.log(reportData)
  useEffect(() => {
    const handleHourlyReport = async () => {
      await fetch(hourly_report_url, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
          }
        })
        .then((response) => {
          if (response.ok) {
            const data = response.json();
            console.log(data);
            setReportData(data);
          } else {
            const data = response.json();
            console.log(data);
            setReportData(data);
            console.error("Failed to subscribe:", response.statusText);
          }
        })
        .catch((error) => {
          const data = error.json();
          console.log(data);
          setReportData(data);
          console.error("Error:", data);
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
        <div>JSON.stringify(reportData)</div>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default Reports;
