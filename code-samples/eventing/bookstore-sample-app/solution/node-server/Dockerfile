# Use a base image with Node.js
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application code to the container
COPY . .

# Expose the port on which the application will run
EXPOSE 8000

# Specify the command to start the application
CMD [ "node", "index.js" ]
