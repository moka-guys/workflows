FROM python:3

COPY src/requirements.txt requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install -r requirements.txt

COPY src/coverage_parser.py coverage_parser.py