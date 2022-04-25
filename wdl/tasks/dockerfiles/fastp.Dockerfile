FROM ubuntu:18.04
RUN apt update && apt install -y \
tabix  \
wget && \
wget http://opengene.org/fastp/fastp && \
chmod a+x ./fastp