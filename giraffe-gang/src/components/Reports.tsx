import React from "react";
import Navbar from "./Navbar.tsx";
import "../styles/Reports.css"; // Import the CSS file

function Reports() {
  return (
    <div className="reports-container">
      <Navbar />

      <h1 className="reports-heading">Reports</h1>
      {/* Add your reports content here */}
    </div>
  );
}

export default Reports;
