# ⚠️  INTENTIONALLY VULNERABLE — FOR SECURITY REVIEW TESTING ONLY ⚠️
# Do NOT use in production.

# Vulnerability 1: Unpinned base image (latest tag) — supply-chain risk
FROM python:latest

# Vulnerability 2: Running as root (no USER instruction)

# Vulnerability 3: Hardcoded secrets in ENV
ENV DB_PASSWORD=supersecret123
ENV AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
ENV AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
ENV SECRET_KEY=my_super_secret_key_do_not_share
ENV API_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Vulnerability 4: Installing packages without pinned versions
RUN pip install flask django requests paramiko

# Vulnerability 5: curl | bash — arbitrary remote code execution
RUN curl -s https://example.com/setup.sh | bash

# Vulnerability 6: Disabling SSL/TLS verification
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host pypi.python.org requests

# Vulnerability 7: Exposing sensitive information via LABEL
LABEL maintainer="admin@company.com"
LABEL db.connection="postgresql://admin:supersecret123@db.internal:5432/prod"

WORKDIR /app

# Vulnerability 8: Copying everything including .git, .env, secrets
COPY . .

# Vulnerability 9: World-writable permissions
RUN chmod -R 777 /app

# Vulnerability 10: Installing unnecessary/dangerous tools
RUN apt-get update && apt-get install -y \
    netcat \
    nmap \
    wget \
    telnet \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Vulnerability 11: Exposing privileged ports
EXPOSE 22
EXPOSE 3306
EXPOSE 5432

# Vulnerability 12: Using ADD with remote URL (instead of safer COPY)
ADD https://example.com/config.tar.gz /app/config/

# Vulnerability 13: sudo installed and used, bypassing container isolation intent
RUN apt-get update && apt-get install -y sudo && \
    echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Vulnerability 14: Running with --privileged-equivalent capabilities implicitly
# (by never dropping capabilities via --cap-drop=ALL)

# Vulnerability 15: Storing secrets in intermediate layer via ARG leak
ARG BUILD_SECRET=production-secret-value
RUN echo $BUILD_SECRET > /tmp/build_secret.txt

CMD ["python", "app.py"]
