FROM python:3.9
RUN pip install multiqc==1.10.1 && \
pip freeze > requirements.txt
