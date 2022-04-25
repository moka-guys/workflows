FROM ubuntu:groovy-20210225
RUN apt update && apt install -y \
wget && \ 
wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary && \
mv bedtools.static.binary /usr/local/bin/bedtools && \
chmod a+x /usr/local/bin/bedtools