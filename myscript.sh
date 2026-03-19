#!/bin/bash
echo "Welcome to Docker pushing"
# docker login

docker build -t flask-app-img .

docker tag flask-app-img malghamdi33/first-docker-hub-flask-img:latest

docker push malghamdi33/first-docker-hub-flask-img:latest

#Remove running conter if exist
docker rm running-flask-app-from-docker-hub

#pull image from docker hub then run it from them.
docker run -it -p 5005:5005 --name running-flask-app-from-docker-hub malghamdi33/first-docker-hub-flask-img:latest

