from typing import Optional
from base64 import b64decode
from io import BytesIO
import json

from fastapi import FastAPI
from pydantic import BaseModel
from google.cloud import storage

from detectionlog.types import DetectionLog


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


def create_app(bucket_name: str) -> FastAPI:
    app = FastAPI()

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)

    def upload_image(image: bytes, name: str) -> str:
        blob = bucket.blob(name)
        blob.upload_from_file(BytesIO(image), content_type="image/jpeg")

        return f"gs://{bucket.name}/{name}"

    @app.get("/")
    async def root(response_model=Response):
        return Response(ok=True)

    @app.post("/")
    async def process(envelope: PubSubEnvelope, response_model=Response):
        message_id = envelope.message.message_id
        print(f"Received message: {message_id}")

        data_json = b64decode(envelope.message.data).decode("utf-8")
        detection_log = DetectionLog(**json.loads(data_json))

        image = b64decode(detection_log.image)
        uri = upload_image(image, f"{message_id}.jpg")
        print(f"Uploaded image: {uri}")

        return Response(ok=True)

    return app
