# Updated from python:latest to a pinned stable patch release to avoid outdated/unbounded base image risk
FROM python:3.12.7-slim

ENV DB_PASSWORD=""
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV SECRET_KEY=""
ENV API_TOKEN=""

RUN pip install --no-cache-dir flask django requests paramiko

RUN curl -fsSL -o /tmp/setup.sh https://example.com/setup.sh && \
    bash /tmp/setup.sh && \
    rm -f /tmp/setup.sh

RUN pip install --no-cache-dir requests

LABEL maintainer="admin@company.com"
LABEL db.connection="postgresql://db.internal:5432/prod"

WORKDIR /app

COPY . .

RUN chmod -R go-w /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gcc \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 22
EXPOSE 3306
EXPOSE 5432

RUN mkdir -p /app/config && \
    curl -fsSL https://example.com/config.tar.gz -o /tmp/config.tar.gz && \
    tar -xzf /tmp/config.tar.gz -C /app/config && \
    rm -f /tmp/config.tar.gz

RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

ARG BUILD_SECRET
RUN test -z "$BUILD_SECRET"

CMD ["python", "app.py"]