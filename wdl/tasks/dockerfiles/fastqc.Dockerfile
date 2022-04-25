FROM ubuntu:18.04
RUN apt update && apt install -y \
build-essential \
openjdk-11-jdk \
wget \
unzip && \
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip && \
unzip fastqc_v0.11.9.zip && \
chmod 755 FastQC/fastqc