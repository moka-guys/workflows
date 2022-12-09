FROM ubuntu:20.04
FROM openjdk:8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install git git-lfs -y python

RUN git init \
    && git remote add origin https://github.com/broadinstitute/gatk \
    && git fetch origin 8dbb78fe789a929a5d18645cc87bad621001797e \
    && git checkout FETCH_HEAD

RUN ./gradlew \
    && ln -s /gatk /usr/local/bin/gatk
