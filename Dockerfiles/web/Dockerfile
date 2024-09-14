# Base-image
FROM node:latest

# set working directory
WORKDIR /app

# copy the package.json and package-lock.json file to the working directory
COPY package*.json /app/

# Install dependencies
RUN npm install

# Copy the rest of the application to the working directory
COPY . /app/

# Expose port 3000 for web services
EXPOSE 3000

# start the application
CMD ["npm","start"]
