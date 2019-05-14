#!/bin/bash
docker stop saturn_testing
docker rm saturn_testing
#docker build --no-cache -t saturn_testing_auto -f package-build/docker/ubuntu_standard/Dockerfile_AutoStartSATurn_UpdateCode .
docker build --no-cache -t saturn_testing -f package-build/docker/ubuntu_standard/Dockerfile_UpdateCode .

sudo docker run -i --restart always --net="host" -v /home/saturn/SGCOxfordTest.json:/home/saturn/SATurn/build/services/DockerConfig.json -v /home/saturn/lib:/home/saturn/lib --name saturn_testing -d saturn_testing
