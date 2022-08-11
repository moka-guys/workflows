# work from latest LTS ubuntu release
FROM ubuntu:20.04

# run update and install necessary tools
RUN apt-get update -y && apt-get install -y \
	git \
	build-essential

RUN git clone https://github.com/niu-lab/msisensor2.git && \
	cd msisensor2 && \
	chmod +x msisensor2 && \
	cp msisensor2 /usr/local/bin  

#Clean up
RUN apt-get clean && apt-get purge \
  && rm -rf /var/lib/apt/lists/* /tmp/*