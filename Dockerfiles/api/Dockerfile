# Base Image - Node.js
FROM node:latest

# set working directory in the docker container
WORKDIR /app

# copy the package.json and package-lock json files to the working directoryCOPY package*.json /app/

# Install dependencies
RUN npm install

# copy the rest of the application to the working directory
COPY . /app/

# Expose port 4000 for the api service
EXPOSE 4000

# start the application
CMD ["npm","start"]