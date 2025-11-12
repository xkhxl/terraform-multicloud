FROM python:3.11-slim


RUN apt-get update && apt-get install -y --no-install-recommends \
dnsmasq curl procps dnsutils supervisor && \
rm -rf /var/lib/apt/lists/*


ENV PYTHONUNBUFFERED=1
WORKDIR /app


COPY watchdog.py .
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY supervisord.conf /etc/supervisord.conf


RUN pip install --no-cache-dir requests


CMD ["supervisord", "-c", "/etc/supervisord.conf"]