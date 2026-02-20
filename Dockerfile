# ---------- Builder Stage ----------
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt

COPY . .

# ---------- Production Stage ----------
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy app source
COPY --from=builder /app /app

# Create non-root user
RUN useradd -m flaskuser
USER flaskuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

