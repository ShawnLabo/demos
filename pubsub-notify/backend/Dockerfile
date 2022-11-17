FROM python:3.11-slim-bullseye

ENV POETRY_NO_INTERACTION=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

RUN pip install poetry && poetry config virtualenvs.create false

COPY poetry.lock /app
COPY pyproject.toml /app

RUN poetry install --no-dev

COPY . /app

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $PORT"]
