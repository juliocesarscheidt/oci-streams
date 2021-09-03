FROM python:3.9-slim

WORKDIR /usr/src/app

COPY requirements.txt .
RUN pip install -r \
    requirements.txt --no-cache-dir
COPY . .

# ENTRYPOINT ["/bin/bash", "-c", "source secrets && python -u consumer.py"]
CMD ["python", "-u", "consumer.py"]
