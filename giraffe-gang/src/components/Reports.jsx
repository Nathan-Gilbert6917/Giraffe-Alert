import React, { useEffect, useState } from "react";
import { Flex } from 'antd';

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
          console.log(result);
          setReportData(result.body);
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
        <div>
          {/* {JSON.stringify(reportData)} */}
          <Flex gap="middle" vertical>
            <Flex gap="middle" horizontal>
              <div style={{backgroundColor: '#DED0B6', width: '25%', padding: "1%",}}><b>ID</b></div>
              <div style={{backgroundColor: '#DED0B6', width: '25%', padding: "1%",}}><b>Date</b></div>
              <div style={{backgroundColor: '#DED0B6', width: '25%', padding: "1%",}}><b>Giraffes</b></div>
              <div style={{backgroundColor: '#DED0B6', width: '25%', padding: "1%", }}><b>Confidence</b></div>
              <div style={{backgroundColor: '#DED0B6', width: '25%', padding: "1%",}}><b>Link</b></div>
            </Flex>
            {JSON.parse(reportData.body).map((item,index)=>{
              return(
                <Flex gap="middle" horizontal>
                  <div key={index} style={{backgroundColor: index % 2 ? '#DED0B6' : '#FAEED1', width: '20%', padding: "1%",}} >{item[0]}</div>
                  <div key={index} style={{backgroundColor: index % 2 ? '#DED0B6' : '#FAEED1', width: '20%', padding: "1%",}} >{item[1]}</div>
                  <div key={index} style={{backgroundColor: index % 2 ? '#DED0B6' : '#FAEED1', width: '20%', padding: "1%",}} >{item[2]}</div>
                  <div key={index} style={{backgroundColor: index % 2 ? '#DED0B6' : '#FAEED1', width: '20%', padding: "1%",}} >{item[3]}</div>
                  <div key={index} style={{backgroundColor: index % 2 ? '#DED0B6' : '#FAEED1', width: '20%', padding: "1%",}} ><a href={item[4]}>{item[4]}</a></div>
                </Flex>
              )
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
