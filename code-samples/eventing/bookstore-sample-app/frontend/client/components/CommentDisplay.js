import Emoji from "./Emoji";

const CommentDisplay = ({ comment }) => {
  // Assume receiving a comment object
  let emoji;
  if (comment.emotion === "positive") {
    emoji = "😃";
  } else if (comment.emotion === "neutral") {
    emoji = "😐";
  } else {
    emoji = "😡";
  }
  return (
    <div className="flex my-4 p-4 justify-center align-middle items-center">
      <div className="comment-display w-full w-7/12 flex flex-row rounded-lg p-4 bg-gray-800 text-white dark:bg-white dark:text-black">
        <div className="flex items-center justify-center md:w-1/12">
          <img
            src={comment.avatar}
            alt="Avatar"
            className="rounded-full w-8 h-8"
          />
        </div>
        <div className="md:w-3/12 flex items-center content-center text-gray-200 dark:text-black">
          {comment.time}
        </div>
        <div className="md:w-9/12 ">
          <span className="h-full flex items-center content-center">
            {comment.text}
          </span>
        </div>
        <div className="md:w-1/12 text-4xl flex">
          <Emoji symbol={emoji} label={comment.emotion} size="text-2xl" />
        </div>
        <div className="md:w-1/12 text-l flex ">
          <button
            type="button"
            className="text-white-700 border border-white-700 hover:bg-white-700 hover:text-white focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center dark:border-blue-800 dark:text-blue-800 dark:hover:text-white dark:focus:ring-blue-800 dark:hover:bg-white"
            disabled={true}
          >
            <svg
              className="w-6 h-6 text-white-800 dark:text-black"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              width="24"
              height="24"
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 7h14m-9 3v8m4-8v8M10 3h4a1 1 0 0 1 1 1v3H9V4a1 1 0 0 1 1-1ZM6 7h12v13a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V7Z"
              />
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
};

export default CommentDisplay;
