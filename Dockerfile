# ⚠️  INTENTIONALLY VULNERABLE — FOR SECURITY REVIEW TESTING ONLY ⚠️
# Do NOT use in production.

# Use a pinned base image tag instead of the moving "latest" tag.
FROM python:3.12.7-slim

# Avoid hardcoded secrets; provide empty defaults to be supplied at runtime.
ENV DB_PASSWORD=""
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV SECRET_KEY=""
ENV API_TOKEN=""

# Install packages without disabling TLS verification and avoid duplicate installs.
RUN pip install --no-cache-dir --upgrade flask django requests paramiko && \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gcc \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Avoid executing remote scripts directly.
RUN curl -fsSL https://example.com/setup.sh -o /tmp/setup.sh && \
    bash /tmp/setup.sh && \
    rm -f /tmp/setup.sh

LABEL maintainer="admin@company.com"
LABEL db.connection="postgresql://admin:${DB_PASSWORD}@db.internal:5432/prod"

WORKDIR /app

COPY . .

RUN chmod -R go-w /app

EXPOSE 22
EXPOSE 3306
EXPOSE 5432

RUN mkdir -p /app/config && \
    curl -fsSL https://example.com/config.tar.gz -o /tmp/config.tar.gz && \
    tar -xzf /tmp/config.tar.gz -C /app/config && \
    rm -f /tmp/config.tar.gz

RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app

ARG BUILD_SECRET
RUN test -z "$BUILD_SECRET"

USER app

CMD ["python", "app.py"]