FROM ubuntu:20.04

# Run update and install necessary tools
RUN apt-get update -y && apt-get install -y git build-essential

RUN mkdir msisensor2 \
    && cd msisensor2 \
    && git init \
    && git remote add origin https://github.com/niu-lab/msisensor2 \
    && git fetch --depth 1 origin e0798c713d62aa56c9672ae8b7e859fa82c17365 \
	&& git checkout FETCH_HEAD \
    && chmod +x msisensor2 \
	&& cp msisensor2 /usr/local/bin