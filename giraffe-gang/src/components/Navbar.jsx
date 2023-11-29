import React from "react";
import { Link } from "react-router-dom";
// import "../styles/Navbar.css";
import { Typography, Input, Button, Space, Alert, Layout, Row, Col } from 'antd';

const { Title } = Typography;

const { Header, Footer, Sider, Content } = Layout;

const headerStyle = {
  textAlign: 'center',
  color: '#fff',
  height: 64,
  paddingInline: 50,
  lineHeight: '64px',
  backgroundColor: "dimgray",
};

const contentStyle = {
  minHeight: 80,
  lineHeight: '100px',
  color: '#fff',
  backgroundColor: "#F5CCA0",
  maxHeight: 200
};

const siderStyle = {
  textAlign: 'center',
  lineHeight: '100px',
  color: '#fff',
  backgroundColor: '#DF826C',
};

function Navbar() {
  return (
        <Row justify="center"style={contentStyle}>
          <Col span={8} style={{textAlign:"right"}}><img src="images/giraffe.png" alt="lil cartoon giraffe" style={{maxHeight: "200px", }}/></Col>
          
          <Col span={8} style={{textAlign:"center"}}>
            <Row justify="center">
              <Typography style={{marginBottom:"0px"}}>
                <Title style={{color: "#361901"}}>Giraffe Gang Presents: Life Giraffe Feed Viewer</Title>
              </Typography>
            </Row>

            <Row  marginTop="5px" align="top">
              <Col span={12} style={{textAlign:"right"}}>
                <Button type="text" size="large" style={{marginTop:"0px"}}>
                  Home
                </Button>
              </Col> 
              <Col span={12} style={{textAlign:"left"}}>
                <Button type="text" size="large">
                  Reports
                </Button>
              </Col>
            </Row>

          </Col>
          
          <Col span={8} style={{textAlign:"left"}}><img src="images/giraffe.png" alt="lil cartoon giraffe" style={{maxHeight: "200px", transform: "scaleX(-1)"}}/></Col>
        </Row>
  );
}

export default Navbar;
