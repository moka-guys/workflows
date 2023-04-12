FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y \
    && apt-get install -y git libnss-sss curl less vim unzip  \
    build-essential libz-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev tabix=1.10.2-3

# Download/install vt
RUN mkdir vt \
    && cd vt \
    && git init \
    && git remote add origin https://github.com/atks/vt \
    && git fetch --depth 1 origin 794f8f5b7b15e723a3455114f58b64b81797ba98 \
	&& git checkout FETCH_HEAD  \
    && git submodule update --init --recursive \
    && make \
    && ln -s /vt/vt /usr/local/bin/vt