FROM ubuntu:groovy-20210225 AS samtools
RUN apt update && apt install -y \
bzip2 \
gcc \
libbz2-dev \
liblzma-dev \
libncurses5-dev \
make \
wget \
zlib1g-dev && \
wget https://github.com/samtools/samtools/releases/download/1.12/samtools-1.12.tar.bz2 && \
tar xfvj samtools-1.12.tar.bz2 && \
rm samtools-1.12.tar.bz2 && \
cd samtools-1.12 && \
./configure --prefix=/usr/local/ && \
make && \
make install

FROM ubuntu:groovy-20210225
COPY --from=samtools /usr/local/bin/samtools /usr/local/bin/samtools
RUN apt update && apt-get install -y \
wget \
git \
openjdk-11-jdk && \
git clone https://github.com/Daniel-Liu-c0deb0t/UMICollapse.git && \
sed -i 's Xmx8G Xmx16G ' UMICollapse/umicollapse && \
sed -i 's umicollapse.jar /umicollapse.jar ' UMICollapse/umicollapse && \
sed -i 's lib/htsjdk-2.19.0.jar /lib/htsjdk-2.19.0.jar ' UMICollapse/Manifest.txt && \
sed -i 's lib/snappy-java-1.1.7.3.jar /lib/snappy-java-1.1.7.3.jar ' UMICollapse/Manifest.txt && \
wget -P lib/ https://repo1.maven.org/maven2/com/github/samtools/htsjdk/2.19.0/htsjdk-2.19.0.jar && \
wget -P lib/ https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.7.3/snappy-java-1.1.7.3.jar && \
mv UMICollapse/src . && \
mv UMICollapse/Manifest.txt . && \
mv UMICollapse/run.sh . && \
mv UMICollapse/umicollapse* .
