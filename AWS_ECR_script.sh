#!/bin/bash
echo "Welcome to AWS ESR pushing"
#
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 410614794148.dkr.ecr.us-east-1.amazonaws.com


docker build -t flask-image-for-ecs-test1 .



docker tag flask-image-for-ecs-test1:latest 410614794148.dkr.ecr.us-east-1.amazonaws.com/flask-image-for-ecs-test1:latest



docker push 410614794148.dkr.ecr.us-east-1.amazonaws.com/flask-image-for-ecs-test1:latest


