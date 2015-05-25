# sshd Jenkins Node
#
# Docker container used in a Jenkins Node role. Contains all necessary build
# tools and SSH daemon configurations for the Jenkins Master to delegate tasks.
#
# SSH configurations based on example provided at
#   https://docs.docker.com/examples/running_ssh_service/
#
# VERSION 14.04.2-2015-05-24

# Latest Ubuntu LTS.
FROM ubuntu:14.04.2
MAINTAINER Brandon Reher <brandon.reher+docker@icloud.com>

# Install SSH server and JDK1.8 for Jenkins build node role.
RUN apt-get update && apt-get -y upgrade && apt-get install -y \ 
    openssh-server \
    openjdk-8-jdk

RUN mkdir /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create Jenkins user.
RUN adduser --quiet jenkins
RUN echo "jenkins:jenkins" | chpasswd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Expose standard SSH daemon port and default daemon startup command.
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
