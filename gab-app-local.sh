#!/bin/bash

# Set variables
APP_NAME="gab-app"
IMAGE_NAME="gab-app"
PORT=3000

echo "---- Building Docker Image ----"
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting."
  exit 1
fi

echo "---- Running Docker Container ----"
docker run --rm -d -p $PORT:3000 --name $APP_NAME $IMAGE_NAME

if [ $? -eq 0 ]; then
  echo "App is running at http://localhost:$PORT"
  echo "To stop the app, run: docker stop $APP_NAME"
  echo "To delete the app, run: docker rmi $APP_NAME"
else
  echo "Failed to start the app."
fi