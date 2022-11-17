import json
import os
from base64 import b64decode
from enum import Enum
from typing import Optional

from fastapi import FastAPI
from pydantic import BaseModel
from google.cloud import firestore


class PubSubMessage(BaseModel):
    attributes: Optional[dict[str, str]]
    data: str
    message_id: str
    messageId: str
    publish_time: str
    publishTime: str


class PubSubEnvelope(BaseModel):
    message: PubSubMessage
    subscription: str


class Response(BaseModel):
    ok: bool


class DogStatus(str, Enum):
    fully_fed = "fully_fed"
    starving = "starving"


class Dog(BaseModel):
    name: str
    status: DogStatus


def get_project_id() -> str:
    if "PROJECT_ID" in os.environ:
        return os.environ["PROJECT_ID"]

    from urllib import request

    req = request.Request(
        "http://metadata.google.internal/computeMetadata/v1/project/project-id",
        headers={"Metadata-Flavor": "Google"}
    )

    with request.urlopen(req) as res:
        return res.read()


db = firestore.Client(project=get_project_id())
app = FastAPI()


@app.get("/")
async def root(response_model=Response):
    return Response(ok=True)


@app.post("/")
async def handle_message(envelope: PubSubEnvelope, response_model=Response):
    message_id = envelope.message.message_id
    print(f"Received message: {message_id}")

    data_json = b64decode(envelope.message.data).decode("utf-8")
    dog = Dog(**json.loads(data_json))
    print(f"Dog: {dog}")

    doc_ref = db.collection("dogs").document(dog.name)
    doc_ref.set({"status": dog.status})

    return Response(ok=True)
