import React, { useEffect, useState } from "react";
import { Table, Tag } from 'antd';

import "../styles/Reports.css";


function Reports() {
  const hourly_report_url = process.env.REACT_APP_ENV_API_URL+"/hourly_report"; //replace with instance url
  const isDemo = process.env.REACT_APP_ENV_DEMO;
  const [reportData, setReportData] = useState(null);

  const normalizeData = (data) =>
    Object.keys(data).map((key) => ({
      id: key,

    }));
  
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
          console.log(result.body);
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
        <div>{JSON.stringify(reportData)}
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Date</th>
              <th>Giraffes</th>
              <th>Confidence</th>
              <th>Link</th>
            </tr>
          </thead>
          <tbody>
            {reportData.map((item,index)=>{
              return(
                <tr>
                  <td>{item[0]}</td>
                  <td>{item[1]}</td>
                  <td>{item[2]}</td>
                  <td>{item[3]}</td>
                  <td>{item[4]}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
        </div>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default Reports;
