import React from "react";
import { useNavigate } from "react-router-dom";
import "../styles/Navbar.css";
import { Typography, Row, Col } from 'antd';

const { Title } = Typography;

const contentStyle = {
  minHeight: 80,
  lineHeight: '100px',
  color: '#fff',
  backgroundColor: "#F5CCA0",
  maxHeight: 200
};

function Navbar() {
  const navigate = useNavigate();
  return (
        <Row justify="center"style={contentStyle}>
          <Col span={8} style={{textAlign:"right"}}><img src="images/giraffe.png" alt="lil cartoon giraffe" style={{maxHeight: "200px", }}/></Col>
          
          <Col span={8} style={{textAlign:"center"}}>
            <Row justify="center">
              <Typography style={{marginBottom:"0px"}}>
                <Title style={{color: "#361901"}}>Giraffe Gang Presents: Life Giraffe Feed Viewer</Title>
              </Typography>
            </Row>

            <Row  marginTop="5px" justify="center">
              <Col span={8} >
                <Typography>
                  <Title className='navbar-link' level={3} onClick={()=>navigate("/")}style={{color:"#361901", marginBlockStart:"0", textAlign:"right"}}>Home</Title>
                </Typography>
              </Col> 
              <Col span={8} >
                <Typography>
                  <Title level={3} style={{color:"#361901", marginBlockStart:"0"}}>|</Title>
                </Typography>
              </Col>
              <Col span={8} >
                <Typography>
                  <Title className='navbar-link'level={3} onClick={()=>navigate("/reports")} style={{color:"#361901", marginBlockStart:"0", textAlign:"left"}}>Reports</Title>
                </Typography>
              </Col>
            </Row>

          </Col>
          
          <Col span={8} style={{textAlign:"left"}}><img src="images/giraffe.png" alt="lil cartoon giraffe" style={{maxHeight: "200px", transform: "scaleX(-1)"}}/></Col>
        </Row>
  );
}

export default Navbar;
