FROM ubuntu:latest
USER root
# Set the working directory to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
# Update image
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install wget nodejs curl -y
# Run
ENTRYPOINT /bin/bash run.sh
