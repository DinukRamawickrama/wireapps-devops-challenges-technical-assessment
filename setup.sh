# Wireapps-DevOps-Challenge--[Dinuk-Kaumika-Ramawickrama]

# 1. Update and upgrade package list
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Install nginx
sudo apt install nginx -y

# 3. Install Docker
sudo apt install docker.io -y

# 4. Install Python3 pip
sudo apt install python3-pip -y

# 5. Remove problematic version of python3-urllib3
sudo apt-get remove python3-urllib3 -y

# 6. Install compatible version of urllib3 using pip
sudo pip install 'urllib3<2' --break-system-packages

# 7. Install Docker Compose
sudo apt install docker-compose -y

# 8. Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 9. Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# 10. Clone the busbud/devops-challenge-apps repository
if [ ! -d "devops-challenge-apps" ]; then
  git clone https://github.com/busbud/devops-challenge-apps.git
fi
cd devops-challenge-apps

# 11. Update npm dependencies
cd web
npm install --legacy-peer-deps || true
npm audit fix --force || true

cd ../api
npm install --legacy-peer-deps || true
npm audit fix --force || true

# 12. Create the Dockerfile for API and add it to the 'api' folder
cd api

cat << 'EOF' > ./Dockerfile
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
EOF

# 13. Create the Dockerfile for Web and add it to the 'web' folder
cd ../web

cat << 'EOF' > ./Dockerfile
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
EOF

# 14. Set up Nginx configuration for host-based routing
sudo bash -c 'cat <<EOL > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name wireapps-web.servehttp.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

server {
    listen 80;
    server_name wireapps-api.servehttp.com;

    location / {
        proxy_pass http://localhost:4000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL'

# 15. Restart Nginx to apply the new configuration
sudo systemctl restart nginx

# 16. Build Docker images for API and Web applications using Docker Compose
cd /devops-challenge-apps

sudo docker-compose down

# Remove old containers and images
sudo docker system prune -f

# 17. Pull or build Docker images and bring up services
# Create docker-compose.yml file
cat <<EOL > /devops-challenge-apps/docker-compose.yml
version: '3.8'

services:
  web:
    build:
      context: ./web
    ports:
      - "3000:3000"
    environment:
      - PORT=3000

  api:
    build:
      context: ./api
    ports:
      - "4000:4000"
    environment:
      - PORT=4000
EOL

# Start Docker Compose
sudo docker-compose up -d

echo "Setup complete! Nginx and Docker services are up and running."


