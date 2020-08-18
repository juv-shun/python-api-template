FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8

LABEL maintainer Shun Fukusumi <shun.fukusumi@gmail.com>

ENV TZ Asia/Tokyo

COPY Pipfile Pipfile.lock ./

RUN pip install -U pip pipenv && pipenv install --system

COPY ./app /app/app
