import React, { useState } from "react";
import Navbar from "./Navbar.jsx";
import LiveFeedImage from "./LiveFeedImage.jsx";
import {API_URL} from "../data/output.js";
import "../styles/Home.css";

function Home() {
  const [email, setEmail] = useState("");
  const [subscribed, setSubscribed] = useState(false);
  const subscription_url = API_URL; //replace with instance url

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
      <Navbar />

      <h1 className="home-heading">Giraffe Gang Live Feed Viewer</h1>

      <LiveFeedImage />

      <div className="subscription-box">
        <p className="subscription-message">
          Don't see any Giraffes? Subscribe to get alerted when they're back!
        </p>
        {!subscribed ? (
          <div className="subscription-form">
            <input
              type="email"
              placeholder="Enter your email"
              value={email}
              onChange={handleEmailChange}
            />
            <button onClick={handleSubscribe}>Subscribe</button>
          </div>
        ) : (
          <div className="thank-you-message">
            <p>
              Thank you for subscribing! Please check your email to confirm
              subscription and you will be alerted via email when Giraffes are
              back.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default Home;

