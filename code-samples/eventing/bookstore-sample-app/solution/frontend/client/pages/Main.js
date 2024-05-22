"use client";
import Header from "../components/Header";
import BookDetail from "../components/BookDetail";
import CommentForm from "../components/CommentForm";
import CommentList from "../components/CommentList";
import { useState } from "react";

const StatusBadge = ({ status }) => {
  if (status == "connecting") {
    return (
      <span className="inline-flex items-center bg-orange-100 text-orange-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-orange-900 dark:text-orange-300">
        <span className="w-2 h-2 me-1 bg-orange-500 rounded-full"></span>
        Connecting
      </span>
    );
  } else if (status == "connected") {
    return (
      <span className="inline-flex items-center bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-green-900 dark:text-green-300">
        <span className="w-2 h-2 me-1 bg-green-500 rounded-full"></span>
        Connected to node server
      </span>
    );
  } else {
    return (
      <span className="inline-flex items-center bg-red-100 text-red-800 text-xs font-medium px-2.5 py-0.5 rounded-full dark:bg-red-900 dark:text-red-300">
        <span class="w-2 h-2 me-1 bg-red-500 rounded-full"></span>
        Service Unavailable
      </span>
    );
  }
};

const InfoAlert = () => {
  return (
    <div
      className="flex items-center p-4 mb-4 text-sm text-blue-800 border border-blue-300 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400 dark:border-blue-800"
      role="alert"
    >
      <svg
        className="flex-shrink-0 inline w-4 h-4 me-3"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5ZM9.5 4a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM12 15H8a1 1 0 0 1 0-2h1v-3H8a1 1 0 0 1 0-2h2a1 1 0 0 1 1 1v4h1a1 1 0 0 1 0 2Z" />
      </svg>
      <span className="sr-only">Info</span>
      <div>
        <span className="font-medium">Note</span> Try implementing the comment
        deletion feature yourself!
      </div>
    </div>
  );
};
export default function Main() {
  /* Example Book object */
  const book = {
    img: "/images/Bookcover.jpg",
    title: "Building serverless applications on Knative",
    author: "Evan Anderson",
    ISBN: "978-1098142070",
    publisher: "Oreilly & Associates Inc",
    publishedDate: "December 19, 2023",
    description:
      "A Guide to Designing and Writing Serverless Cloud Application",
    price: "$49",
  };

  const [status, setStatus] = useState("connecting");
  
  return (
    <div>
      <Header />

      <main className="container mx-auto my-8">
        <BookDetail book={book} />
        <div className="max-w-4xl mx-auto">
          <CommentForm />
          <p className="text-xl font-semibold mt-6 mb-4 text-gray-800 dark:text-gray-200">
            Comments <StatusBadge status={status} />
          </p>
          <InfoAlert />
          <CommentList setStatus={setStatus} />
        </div>
      </main>
    </div>
  );
}
