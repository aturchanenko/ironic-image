# ⚠️  INTENTIONALLY VULNERABLE — FOR SECURITY REVIEW TESTING ONLY ⚠️
# Do NOT use in production.

# Updated from unpinned latest tag to a pinned Python 3 base image for reproducible, safer builds
FROM python:3.12-slim

ENV DB_PASSWORD=""
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV SECRET_KEY=""
ENV API_TOKEN=""

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir flask django requests paramiko

RUN curl -fsSL https://example.com/setup.sh -o /tmp/setup.sh && \
    bash /tmp/setup.sh && \
    rm -f /tmp/setup.sh

LABEL maintainer="admin@company.com"
LABEL db.connection="postgresql://db.internal:5432/prod"

COPY . .

RUN chmod -R go-w /app

RUN apt-get update && apt-get install -y --only-upgrade libexpat1 libsqlite3-0 libssl3 openssl zlib1g && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 22
EXPOSE 3306
EXPOSE 5432

ADD https://example.com/config.tar.gz /app/config/

RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

ARG BUILD_SECRET
RUN test -z "$BUILD_SECRET"

CMD ["python", "app.py"]