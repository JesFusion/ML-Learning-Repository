FROM python:3.10-slim

WORKDIR /the_files

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


COPY script.py .

CMD ["python", "script.py"]

