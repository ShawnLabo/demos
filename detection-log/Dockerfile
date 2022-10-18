FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=True
ENV POETRY_NO_INTERACTION=1
ENV WEB_CONCURRENCY=1
ENV PORT=8080

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml ./
COPY poetry.toml ./
COPY poetry.lock ./

RUN poetry install --no-dev

COPY . /app

ENTRYPOINT ["poetry"]
