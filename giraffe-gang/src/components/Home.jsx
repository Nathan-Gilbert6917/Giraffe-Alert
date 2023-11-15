import React, { useState } from "react";
import Navbar from "./Navbar.jsx";
import LiveFeedImage from "./LiveFeedImage.jsx";
import "../styles/Home.css";

function Home() {
  const [email, setEmail] = useState("");
  const [subscribed, setSubscribed] = useState(false);

  const handleEmailChange = (e) => {
    setEmail(e.target.value);
  };

  const handleSubscribe = () => {
    // add backend call here
    setSubscribed(true);
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
              Thank you for subscribing! You will be alerted via email when
              Giraffes are back.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default Home;
