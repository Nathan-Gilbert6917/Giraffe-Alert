import React from "react";
import { useNavigate } from "react-router-dom";
import "../styles/Navbar.css";
import { Typography, Row, Col } from "antd";

const { Title } = Typography;

const contentStyle = {
  minHeight: 80,
  color: "#fff",
  backgroundColor: "#F5CCA0",
  maxHeight: 200,
};

function Navbar() {
  const navigate = useNavigate();
  return (
    <Row justify="space-between" style={contentStyle}>
      <Col span={4} style={{ textAlign: "left" }}>
        <img
          src="images/giraffe.png"
          alt="lil cartoon giraffe"
          style={{ maxHeight: "170px", paddingLeft: "5em" }}
        />
      </Col>

      <Col span={16} style={{ textAlign: "center" }}>
        <Row justify="center">
          <Typography style={{ marginBottom: "0px" }}>
            <Title style={{ color: "#361901" }}>
              Giraffe Gang Presents: Live Giraffe Feed Viewer
            </Title>
          </Typography>
        </Row>

        <Row marginTop="5px" justify="center">
          <Col span={8}>
            <Typography>
              <Title
                className="navbar-link"
                level={2}
                onClick={() => navigate("/")}
                style={{
                  color: "#361901",
                  marginBlockStart: "0",
                  textAlign: "right",
                  textDecoration: "underline",
                  paddingTop: "1em",
                }}
              >
                Home
              </Title>
            </Typography>
          </Col>
          <Col span={8}>
            <Typography>
              <Title
                level={2}
                style={{
                  color: "#361901",
                  marginBlockStart: "0",
                  paddingTop: "1em",
                }}
              >
                |
              </Title>
            </Typography>
          </Col>
          <Col span={8}>
            <Typography>
              <Title
                className="navbar-link"
                level={2}
                onClick={() => navigate("/report")}
                style={{
                  color: "#361901",
                  marginBlockStart: "0",
                  textAlign: "left",
                  textDecoration: "underline",
                  paddingTop: "1em",
                }}
              >
                Report
              </Title>
            </Typography>
          </Col>
        </Row>
      </Col>

      <Col span={4} style={{ textAlign: "right" }}>
        <img
          src="images/giraffe.png"
          alt="lil cartoon giraffe"
          style={{
            maxHeight: "170px",
            transform: "scaleX(-1)",
            paddingLeft: "5em",
          }}
        />
      </Col>
    </Row>
  );
}

export default Navbar;
