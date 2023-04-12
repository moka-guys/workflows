FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y  \
    && apt-get install -y git libnss-sss curl less vim unzip build-essential libz-dev  \
    libbz2-dev liblzma-dev libcurl4-openssl-dev libssl-dev libisal-dev libdeflate-dev

# Download/install fastp
RUN git init \
    && git remote add origin https://github.com/OpenGene/fastp \
    && git fetch --depth 1 origin 254ec78538eee62b3f2627505d606d99000241d2 \
    && git checkout FETCH_HEAD  \
    && ln -s /usr/lib/libz.so.1.2.8 /usr/lib/libzlib.so \
    && make \
    && make install \
    && cd ..