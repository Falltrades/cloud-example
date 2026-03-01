FROM python:3.12-slim AS build

WORKDIR /app

RUN pip install websockets==13.1

COPY server.py .

EXPOSE 3001

CMD ["python", "-u", "server.py"]
