FROM python:3

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install -r requirements.txt

COPY src/parse_coverage_by_gene.py parse_coverage_by_gene.py

RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary &&\
    mv bedtools.static.binary bedtools &&\
    chmod a+x bedtools &&\
    cp bedtools /usr/local/bin/

ENV PATH=${PATH}:/usr/local/bin/bedtools


