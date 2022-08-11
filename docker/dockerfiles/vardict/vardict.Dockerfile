FROM debian:stable-slim
FROM openjdk:8

ENV vardict_version 1.8.0

RUN apt-get update && apt-get install -y software-properties-common
RUN apt-get install -y \
    git \
    wget \
    r-base

RUN git clone --recursive https://github.com/AstraZeneca-NGS/VarDictJava.git

RUN cd VarDictJava/ && ./gradlew clean installDist && unzip dist/VarDict-$vardict_version.zip 

ENV PATH="/VarDictJava/VarDict-$vardict_version/bin:${PATH}"

ENV PATH=$PATH:/bin