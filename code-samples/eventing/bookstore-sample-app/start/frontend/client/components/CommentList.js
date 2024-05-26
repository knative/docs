import React, {useEffect, useState} from "react";
import CommentDisplay from "./CommentDisplay";

const CommentList = ({setStatus}) => {
    const [comments, setComments] = useState([]);

    useEffect(() => {
        const ws = new WebSocket("ws://localhost:8080/comments");

        ws.onmessage = (event) => {
            const newComments = JSON.parse(event.data);
            setComments(newComments);
        };

        ws.onopen = () => {
            console.log("Connected to /comments");
            setStatus("connected");
        };

        ws.onclose = () => {
            console.log("Disconnected from /comments");
            setStatus("connecting");
        };

        ws.onerror = (error) => {
            console.error("WebSocket error:", error);
            setStatus("connecting");
        };

        return () => {
            ws.close();
        };
    }, []);

    return (
        <div>

            {comments.length > 0 ? comments.map((comment, index) => (
                <CommentDisplay
                    key={index}
                    comment={{
                        avatar: "/images/avatar.jpg", // assuming a static avatar for each comment
                        time: new Date(comment.post_time).toLocaleDateString("en-US", {
                            month: "short",
                            day: "numeric",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                            hour12: false,
                        }),
                        text: comment.content,
                        emotion: comment.sentiment,
                    }}
                />
            )) : <p>No comments available</p>}
        </div>
    );
};

export default CommentList;
