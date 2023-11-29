import React from "react";
import { Link } from "react-router-dom";
// import "../styles/Navbar.css";
import { Typography, Input, Button, Space, Alert, Layout } from 'antd';

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
  textAlign: 'right',
  minHeight: 80,
  lineHeight: '100px',
  color: '#fff',
  backgroundColor: "#F5CCA0",
  paddingRight: "3%",
};

const siderStyle = {
  textAlign: 'center',
  lineHeight: '100px',
  color: '#fff',
  backgroundColor: '#DF826C',
};

function Navbar() {
  return (
    <Space direction="vertical" style={{ width: '100%' }} size={[0, 48]}>
      <Layout hasSider>
        <Sider style={siderStyle}>
          <img src= "images/giraffe.png" alt="lil cartoon giraffe" style={{width: "100%", height:"100%", margin: "auto", paddingRight: "60%", left: "30%", position: "absolute", textAlign: 'center'}}/>
        </Sider>
        <Content style={contentStyle}>
          
          {/* <Typography>
            <Title level={3} style={{paddingleft: "10%", marginBottom: '10px', textAlign: 'left',}}>Giraffe Gang Presents: Live Giraffe Feed Viewer</Title>
          </Typography> */}
          <Button>
            <Link to="/" className="navbar-link">
              Home
            </Link>
          </Button>
          <Button>
            <Link to="/reports" className="navbar-link">
              Reports
            </Link>
          </Button>
        </Content>
      </Layout>
    </Space>
    // <nav className="navbar">
      
    // </nav>
  );
}

export default Navbar;
