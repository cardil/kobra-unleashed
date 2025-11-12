# Use node.js image as builder to build the frontend
FROM node:21-alpine as builder
WORKDIR /js
COPY kobra-client /js
RUN pwd && npm install && npm run build

FROM python:3.12-alpine

# Set work directory
WORKDIR /app
# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV CORS_ALLOWED_ORIGINS="*"

EXPOSE 5000

# Copy project
COPY Pipfile Pipfile.lock main.py /app/
COPY --from=builder /js/dist /app/kobra-client/dist

VOLUME /app/certs

# Install python dependencies
RUN pip install pipenv && \
    pipenv requirements > ./requirements.txt && \
    pip install -r ./requirements.txt



CMD gunicorn --bind :5000 --worker-class eventlet --workers 1 'main:app'