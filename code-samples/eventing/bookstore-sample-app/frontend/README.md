# Getting Started

This app use Next.js and TailwindCSS as main packages. Use this command to install all dependencies:

```bash
npm install
```

To run application, use:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

# Project Structures

- app/: Contains the main layout, page, and global styling.
- client/: Contains components and pages used in the application.
- public/images/: Contains image files.
- next-env.d.ts, next.config.mjs, package-lock.json, package.json, postcss.config.js, tailwind.config.js, tsconfig.json: Configuration files for Next.js, Tailwind CSS, and TypeScript.

# Containerize Application

This repository contains a Next.js application that utilizes next-themes and Tailwind CSS. This README file provides instructions on how to containerize the application using Docker.

## Prerequisites

- Docker installed on your machine. You can download and install Docker from [here](https://www.docker.com/get-started).

## Dockerization Steps

1. Clone this repository to your local machine.
2. Navigate to the root directory of the cloned repository.

### Building the Docker Image

Run the following command to build the Docker image:

```bash
docker build -t frontend .
```

## Running the Docker Container

Once the image is built, you can run a container using the following command:

```bash
docker run -d -p 3000:3000 frontend
```

## Dockerfile for containerization

```Dockerfile
# Use a base image with Node.js LTS
FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application code to the working directory
COPY . .

# Build the Next.js application
RUN npm run build

# Expose the port your app runs on
EXPOSE 3000

# Define the command to run your app
CMD ["npm", "run dev"]
```
