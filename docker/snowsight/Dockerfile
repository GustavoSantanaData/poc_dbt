FROM python:3.12-slim

WORKDIR /app
RUN pip install --no-cache-dir trino==0.340.0
COPY sql_ui.py /app/sql_ui.py

ENV BIND_HOST=0.0.0.0
ENV PORT=8501
ENV TRINO_HOST=trino
ENV TRINO_PORT=8080

EXPOSE 8501
CMD ["python", "-u", "/app/sql_ui.py"]
