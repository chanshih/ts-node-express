# Use an official lightweight Node.js image.
FROM public.ecr.aws/docker/library/node:24-alpine

# Set the working directory in the container.
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies.
RUN npm install

# Copy the rest of the source code.
COPY . .

# Build the project (assuming tsc is configured to output to the 'dist' folder)
RUN npm run build

# Expose the port
EXPOSE 8000

# Start the application.
CMD ["npm", "start"]