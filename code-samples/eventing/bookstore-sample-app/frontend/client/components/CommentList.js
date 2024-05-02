import React, { useEffect, useState } from "react";
import CommentDisplay from "./CommentDisplay";

const CommentList = () => {
  const [comments, setComments] = useState([]);

  useEffect(() => {
    const ws = new WebSocket("ws://localhost:8080/comments");

    ws.onmessage = (event) => {
      const newComments = JSON.parse(event.data);
      setComments(newComments);
    };

    ws.onopen = () => {
      console.log("Connected to /comments");
    };

    ws.onclose = () => {
      console.log("Disconnected from /comments");
    };

    ws.onerror = (error) => {
      console.error("WebSocket error:", error);
    };

    return () => {
      ws.close();
    };
  }, []);

  return (
    <div>
      {comments.map((comment, index) => (
        <CommentDisplay
          key={index}
          comment={{
            avatar: "/images/avatar.jpg", // assuming a static avatar for each comment
            time: new Date(comment.post_time).toLocaleTimeString(),
            text: comment.content,
            emotion: comment.sentiment,
          }}
        />
      ))}
    </div>
  );
};

export default CommentList;
