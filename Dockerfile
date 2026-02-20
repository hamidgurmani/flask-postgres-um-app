# ----- build Stage-----
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt

COPY . . 

# ----- production stage -----

FROM python:3.11-slim

WORKDIR /app

RUN useradd -m flaskuser

USER flaskuser

COPY --from=builder /root/.local /home/flaskuser/.local
COPY --from=builder /app /app

ENV PATH=/home/flaskuser/.local/bin:$PATH

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

