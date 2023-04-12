FROM openjdk:8

RUN apt-get update
RUN apt-get install -y git perl
RUN apt-get install -y --no-install-recommends r-base

RUN git clone --recursive https://github.com/AstraZeneca-NGS/VarDictJava.git
RUN cd VarDictJava \
    && git checkout a7f4e77a118e6bc8bfb96f57237e3dbeca823ad9 \
    && ./gradlew clean installDist \
    && cd .. \
    && mv /VarDictJava/build/install/VarDict . \
    && rm -r VarDictJava

ENV PATH=/VarDict/bin:$PATH