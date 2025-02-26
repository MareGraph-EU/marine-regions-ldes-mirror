# Start from a Node.js ready image
FROM node:lts-alpine
# Set current working directory
WORKDIR /ldes-solid-server
# Copy configuration files
COPY . .
# Install dependencies
RUN npm ci
# Open TCP port 3000
EXPOSE 3000
# Set command run by the container
RUN chmod +x run.sh
ENTRYPOINT ["./run.sh"]