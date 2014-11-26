#!/usr/bin/bash

docker run -d -p 50000:50000 -p 9999:8080 --name jenkins --volume=/src/jenkins:/var/jenkins_home jenkins:1.565.3
