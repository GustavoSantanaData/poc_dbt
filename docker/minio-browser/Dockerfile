FROM python:3.12-slim

WORKDIR /app
RUN pip install --no-cache-dir minio==7.2.20
COPY minio_ui.py /app/minio_ui.py

ENV BIND_HOST=0.0.0.0
ENV PORT=9001
ENV MINIO_ENDPOINT=minio:9000
ENV MINIO_BUCKET=warehouse

EXPOSE 9001
CMD ["python", "-u", "/app/minio_ui.py"]
