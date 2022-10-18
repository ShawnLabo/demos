from pydantic import BaseModel


class Point(BaseModel):
    x: float
    y: float


class ObjectAnnotation(BaseModel):
    name: str
    score: float
    bounding_poly: list[Point]


class DetectionLog(BaseModel):
    image: str
    annotations: list[ObjectAnnotation]
