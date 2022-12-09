FROM ubuntu:20.04
FROM openjdk:8

RUN apt-get update
RUN apt-get install -y git

RUN mkdir VarDictJava \
    && cd VarDictJava \
    && git init \
    && git remote add origin https://github.com/AstraZeneca-NGS/VarDictJava \
    && git fetch --depth 1 origin a7f4e77a118e6bc8bfb96f57237e3dbeca823ad9 \
	&& git checkout FETCH_HEAD \
    && ./gradlew clean installDist

ENV PATH=/VarDictJava/build/install/VarDict/bin:$PATH