"use-client";
import {useState} from "react";

const GreenCheckMark = () => {
    return (
        <svg
            className="w-4 h-4 me-2 text-green-500 dark:text-green-400 flex-shrink-0"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            viewBox="0 0 20 20"
        >
            <path
                d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"/>
        </svg>
    );
};

const KuackImage = () => {
    return (
        <img
            src="https://i.ibb.co/hD1gG7q/Knative-Bookstore-3.png"
            alt="Descriptive Alt Text"
            className="w-24 mr-8 mt-4 mb-4"
        />
    );
};

const GreyLoadingSpin = () => {
    return (
        <div role="status">
            <svg
                aria-hidden="true"
                className="w-4 h-4 me-2 text-gray-200 animate-spin dark:text-gray-600 fill-blue-600"
                viewBox="0 0 100 101"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                    fill="currentColor"
                />
                <path
                    d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                    fill="currentFill"
                />
            </svg>
            <span className="sr-only">Loading...</span>
        </div>
    );
};

const RedXMark = () => {
    return (
        <svg
            className="w-4 h-4 me-2 text-red-500 dark:text-red-400 flex-shrink-0"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            viewBox="0 0 20 20"
        >
            <path
                d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm2.828 12.828a1 1 0 0 1-1.414 0L10 11.414l-1.414 1.414a1 1 0 0 1-1.414-1.414L8.586 10 7.172 8.586a1 1 0 1 1 1.414-1.414L10 8.586l1.414-1.414a1 1 0 0 1 1.414 1.414L11.414 10l1.414 1.414a1 1 0 0 1 0 1.414Z"/>
        </svg>
    );
};

const GreyCheckMark = () => {
    return (
        <svg
            className="w-4 h-4 me-2 text-grey-500 dark:text-grey-400 flex-shrink-0"
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            viewBox="0 0 20 20"
        >
            <path
                d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z"/>
        </svg>
    );
};

const StatusProgress = ({
                            comment,
                            loadingState,
                            everSubmit,
                            responseSuccess,
                        }) => {
    return (
        <div
            className="flex justify-between items-center p-6 bg-white border border-gray-100 rounded-lg shadow-md dark:bg-gray-800 dark:border-gray-800 dark:hover:bg-gray-700">
            <div className="flex-1">
                <h2 className="mb-2 text-lg font-semibold text-gray-900 dark:text-white">
                    The process behind your Event Driven Architecture:
                </h2>
                {everSubmit ? (
                    <ul className="space-y-2 text-gray-500 list-inside dark:text-gray-400">
                        <li className="flex items-center text-black dark:text-white">
                            <div className="font-bold p-1">The comment you submitted:</div>
                            {comment}
                        </li>
                        <li className="flex items-center">
                            <GreenCheckMark/>
                            Your comment has been packed as a CloudEvent
                        </li>
                        <li className="flex items-center">
                            <GreenCheckMark/>
                            The CloudEvent has been sent to Nodejs Server as a POST request
                            via HTTP
                        </li>
                        <li className="flex items-center">
                            <GreenCheckMark/>
                            Nodejs Server may forwarded the event to Broker
                        </li>
                        <li className="flex items-center">
                            {responseSuccess === "unknown" && <GreyLoadingSpin/>}
                            {responseSuccess === "error" && <RedXMark/>}
                            {responseSuccess === "success" && <GreenCheckMark/>}
                            {responseSuccess === "error"
                                ? "The CloudEvent has been dispatched by Broker, but got error response."
                                : "The CloudEvent has been dispatched by Broker, waiting for an acknowledgement."}
                        </li>
                        <li className="flex items-center">
                            {responseSuccess === "success" ? (
                                <GreenCheckMark/>
                            ) : (
                                <GreyCheckMark/>
                            )}
                            Acknowledgement received, the cycle has been completed!
                        </li>
                        <li className="flex items-center">
                            {responseSuccess === "success" ? (
                                <GreenCheckMark/>
                            ) : (
                                <GreyCheckMark/>
                            )}
                            Wait a few seconds until the system finishes processing the
                            comment
                        </li>
                    </ul>
                ) : (
                    <h1>Try submitting something first!</h1>
                )}
            </div>
            <KuackImage/>
        </div>
    );
};

const CommentForm = () => {
    const [hover, setHover] = useState(false);
    const [comment, setComment] = useState("");
    const [loadingState, setLoadingState] = useState(false);
    const [responseSuccess, setResponseSuccess] = useState("unknown");
    const [everSubmit, setEverSubmit] = useState(false);

    const handleInputChange = (event) => {
        setComment(event.target.value);
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        setLoadingState(true);
        setEverSubmit(true);
        setResponseSuccess("unknown");

        fetch("http://localhost:8080/add", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Ce-Type": "new-review-comment", // Assuming CloudEvents standard
                "Ce-Specversion": "1.0",
                "Ce-Source": "commentForm",
                "Ce-Id": "unique-comment-id",
            },
            body: JSON.stringify({
                reviewText: comment,
            }),
        })
            .then((response) => {
                if (response.status === 200) {
                    return response.json();
                } else {
                    setResponseSuccess("error");
                    setLoadingState(true);
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
            })
            .then((data) => {
                console.log("Success:", data);
                setResponseSuccess("success");
                setLoadingState(true);
            })
            .catch((error) => {
                console.error("Error:", error);
            });
    };

    const handleReset = () => {
        setLoadingState(false);
        setComment("");
        setResponseSuccess("unknown");
        setEverSubmit(false);
    };

    return (
        <div>
            <StatusProgress
                comment={comment}
                loadingState={loadingState}
                everSubmit={everSubmit}
                responseSuccess={responseSuccess}
            />

            <div className="flex my-4 p-4 justify-center ">
                <form
                    className="w-full w-8/12 flex flex-col items-end "
                    onSubmit={handleSubmit}
                >
          <textarea
              className="form-textarea w-full mb-2 p-2 border border-2 border-black rounded-lg p-4"
              rows="3"
              placeholder="Leave your comment here..."
              value={comment}
              onChange={handleInputChange}
              disabled={loadingState}
          ></textarea>

                    {loadingState ? null : (
                        <button
                            type="submit"
                            className={`font-bold py-2 px-9 rounded ${
                                hover ? "" : "bg-blue-600"
                            }`}
                            disabled={comment === ""}
                            style={{
                                backgroundColor:
                                    comment === "" ? "#c3c6c7" : hover ? "#baeafd" : "#A5D8FF",
                            }}
                            onMouseEnter={() => setHover(true)}
                            onMouseLeave={() => setHover(false)}
                        >
                            Submit
                        </button>
                    )}
                    {responseSuccess !== "unknown" && (
                        <div className="flex flex-col">
                            <button
                                type="button"
                                onMouseEnter={() => setHover(true)}
                                onMouseLeave={() => setHover(false)}
                                onClick={handleReset}
                                className={`font-bold py-2 px-9 rounded ${
                                    hover ? "" : "bg-blue-600"
                                }`}
                                style={{backgroundColor: hover ? "#bfcaff" : "#9aa8ff"}}
                            >
                                Reset
                            </button>
                        </div>
                    )}
                </form>
            </div>
        </div>
    );
};

export default CommentForm;
