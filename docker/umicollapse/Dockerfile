FROM ubuntu:20.04 AS samtools

RUN apt-get update -y \
    && apt install -y bzip2 gcc libbz2-dev liblzma-dev libncurses5-dev make wget zlib1g-dev git autoconf curl

# Download/install htslib
RUN mkdir htslib \
    && cd htslib \
    && git init \
    && git remote add origin https://github.com/samtools/htslib \
    && git fetch --depth 1 origin 4e61c128238f3e7cbb3b1f4e9c0fdb4880aa9a10 \
	&& git checkout FETCH_HEAD \
    && git submodule update --init --recursive \
    && autoreconf -i && \
    ./configure &&  \
    make && \
    make install \
    && cd ..

# Download/install samtools
RUN mkdir samtools \
    && cd samtools \
    && git init \
    && git remote add origin https://github.com/samtools/samtools/ \
    && git fetch --depth 1 origin c3a29a9878b58fe2b0ae3e0ae782e6a3b8c4d0de \
	&& git checkout FETCH_HEAD \
    && autoheader \
    && autoconf -Wno-syntax \
    && ./configure --prefix=/usr/local/ \
    && make \
    && make install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
COPY --from=samtools /usr/local/bin/samtools /usr/local/bin/samtools

RUN apt-get update  \
    && apt-get install -y wget git openjdk-11-jdk

# Download/install umicollapse
RUN mkdir UMIcollapse \
    && cd UMIcollapse \
    && git init \
    && git remote add origin https://github.com/Daniel-Liu-c0deb0t/UMICollapse \
    && git fetch --depth 1 origin 88d7949c4de68886d07712763cfecc1d3962521a \
    && git checkout FETCH_HEAD \
    && sed -i 's Xmx8G Xmx16G ' umicollapse \
    && sed -i 's umicollapse.jar /UMIcollapse/umicollapse.jar ' umicollapse \
    && sed -i 's lib/htsjdk-2.19.0.jar /lib/htsjdk-2.19.0.jar ' Manifest.txt \
    && sed -i 's lib/snappy-java-1.1.7.3.jar /lib/snappy-java-1.1.7.3.jar ' Manifest.txt \
    && cd .. \
    && wget -P lib/ https://repo1.maven.org/maven2/com/github/samtools/htsjdk/2.19.0/htsjdk-2.19.0.jar \
    && wget -P lib/ https://repo1.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.7.3/snappy-java-1.1.7.3.jar \
    && ln -s /UMIcollapse/umicollapse /usr/local/bin/umicollapse