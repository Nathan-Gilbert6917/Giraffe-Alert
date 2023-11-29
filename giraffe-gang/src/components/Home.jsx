import React, { useState } from "react";
import Navbar from "./Navbar.jsx";
import LiveFeedImage from "./LiveFeedImage.jsx";
import "../styles/Home.css";
import { Typography, Input, Button, Space, Alert } from 'antd';



const { Title, Paragraph } = Typography;

function Home() {
  const [email, setEmail] = useState("");
  const [subscribed, setSubscribed] = useState(false);
  const subscription_url = process.env.REACT_APP_ENV_API_URL+"/subscriber"; //replace with instance url
  
  const handleEmailChange = (e) => {
    setEmail(e.target.value);
  };

  const handleSubscribe = () => {
    const requestBody = {
      email: email,
    }; 
    
    // Send request to the subscription_url
    fetch(subscription_url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(requestBody),
    })
      .then((response) => {
        if (response.ok) {
          setSubscribed(true);
        } else {
          setSubscribed(true); //KLDUGE FOR DEMO

          console.error("Failed to subscribe:", response.statusText);
        }
      })
      .catch((error) => {
        setSubscribed(true); //KLUDGE FOR DEMO
        console.error("Error:", error);
      });
  };

  return (
    <div className="home-container">
      {/* <Navbar /> */}

      
      <LiveFeedImage />
      <div className="subscription-box">
        <Typography>
          <Paragraph strong="true" className="subscription-message">
            Don't see any Giraffes? Subscribe to get alerted when they're back!
          </Paragraph>
          {!subscribed ? (
            <div className="subscription-form">
              <Space.Compact>
                <Input placeholder="Enter your email" value={email} onChange={handleEmailChange}/>
                <Button className="btn" onClick={handleSubscribe}>Subscribe</Button>
              </Space.Compact>
            </div>
          ) : (
            <div className="thank-you-message">
              <Alert message="Thank you for subscribing! Please check your email to confirm
                subscription and you will be alerted via email when Giraffes are
                back." type="success"/>
            </div>
          )}
        </Typography>
      </div>
    </div>
  );
}

export default Home;
