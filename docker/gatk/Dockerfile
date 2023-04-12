FROM openjdk:8 AS gatk

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y git git-lfs python

RUN git clone https://github.com/broadinstitute/gatk.git \
    && cd gatk \
    && git checkout 8dbb78fe789a929a5d18645cc87bad621001797e

RUN cd gatk \
    && ./gradlew

RUN cd /gatk/build \
    && unzip gatk-4.3.0.0-SNAPSHOT.zip

FROM openjdk:8
# Only copy over required files to reduce large image size
COPY --from=gatk /gatk/build/gatk-4.3.0.0-SNAPSHOT /gatk-4.3.0.0-SNAPSHOT

RUN apt-get update -y \
    && apt-get install -y python

ENV PATH=/gatk-4.3.0.0-SNAPSHOT/:$PATH