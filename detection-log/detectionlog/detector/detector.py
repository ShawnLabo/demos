from base64 import b64encode

from google.cloud import vision, pubsub

from detectionlog.types import Point, ObjectAnnotation, DetectionLog


def detect(image_data: bytes) -> ObjectAnnotation:
    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=image_data)
    objects = client.object_localization(
        image=image).localized_object_annotations

    annotations = []

    for obj in objects:
        vertices = obj.bounding_poly.normalized_vertices

        annotations.append(ObjectAnnotation(
            name=obj.name,
            score=obj.score,
            bounding_poly=[Point(x=v.x, y=v.y) for v in vertices]
        ))

    return annotations


class LogPublisher:
    def __init__(self, project_id: str, topic_id: str):
        self._project_id = project_id
        self._topic_id = topic_id

    def publish(self,
                image_data: bytes,
                annotations: list[ObjectAnnotation]
                ) -> str:

        encoded_image = b64encode(image_data).decode()
        log = DetectionLog(image=encoded_image, annotations=annotations)

        publisher = pubsub.PublisherClient()
        topic_path = publisher.topic_path(self._project_id, self._topic_id)

        data = log.json().encode("utf-8")
        future = publisher.publish(topic_path, data)

        return future.result()
