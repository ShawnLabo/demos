import json
import os
import sys

from google.cloud import pubsub_v1 as pubsub


def main(name: str, status: str) -> None:
    client = pubsub.PublisherClient()

    topic_path = client.topic_path(os.environ["PROJECT_ID"], "dog-status")

    data = {
        "name": name,
        "status": status,
    }

    future = client.publish(topic_path, json.dumps(data).encode("utf-8"))
    future.result()

    print("Published")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
