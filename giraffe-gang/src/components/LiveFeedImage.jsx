import React, { useState, useEffect } from "react";

const LiveFeedImage = () => {
  const [liveFeedImg, setLiveFeedImg] = useState("");

  const fetchSessionKey = async () => {
    const sessionUrl =
      "https://relay.ozolio.com/ses.api?cmd=init&oid=CID_IYVU0000014B&ver=5&channel=0&control=1&document=https%3A%2F%2Fwww.houstonzoo.org%2Fexplore%2Fwebcams%2Fgiraffe-feeding-platform%2F";
    try {
      const response = await fetch(sessionUrl);
      const data = await response.json();
      return data.session.id;
    } catch (error) {
      console.error("Error fetching session key: ", error);
    }
  };

  const fetchImage = async (sessionKey) => {
    try {
      const imageUrl = `https://relay.ozolio.com/pub.api?cmd=poster&oid=${sessionKey}`;
      const response = await fetch(imageUrl);
      const imageBlob = await response.blob();
      const imageObjectURL = URL.createObjectURL(imageBlob);
      setLiveFeedImg(imageObjectURL);
    } catch (error) {
      console.error("Error fetching image:", error);
    }
  };

  useEffect(() => {
    let intervalId;

    const getSessionKeyAndFetchImage = () => {
      fetchSessionKey()
        .then((sessionKey) => {
          if (sessionKey) {
            return fetchImage(sessionKey);
          }
        })
        .catch((error) => {
          console.error("Error in getSessionKeyAndFetchImage:", error);
        });
    };

    getSessionKeyAndFetchImage();

    intervalId = setInterval(() => {
      getSessionKeyAndFetchImage();
    }, 1000); // Fetch new image every second

    return () => clearInterval(intervalId); // Clear interval on component unmount
  }, []);

  return (
    <div className="live-feed-box">
      {liveFeedImg ? (
        <img
          src={liveFeedImg}
          alt="Live Houston Zoo Giraffe Feed"
          className="live-feed-image"
        />
      ) : (
        <p>Loading live feed...</p>
      )}
    </div>
  );
};

export default LiveFeedImage;
