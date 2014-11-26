#!/usr/bin/bash

docker run -d -p 8888:8080 --name artifactory --volume=/src/artifactory/data:/artifactory/data --volume=/src/artifactory/logs:/artifactory/logs --volume=/src/artifactory/backups:/artifactory/backups mattgruter/artifactory:3.4.1
