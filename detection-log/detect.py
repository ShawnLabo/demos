import os
import sys

from detectionlog.detector import detect, LogPublisher


def main():
    if len(sys.argv) != 2:
        print("Error!\n\nUsage: main.py IMAGE_FILE\n", file=sys.stderr)
        sys.exit(1)

    image_path = sys.argv[1]

    with open(image_path, "rb") as f:
        image_data = f.read()

    annotations = detect(image_data)
    print(f"Detected objects in {image_path}:")
    print(annotations)

    publisher = LogPublisher(
        os.environ.get("PROJECT_ID"), os.environ.get("LOG_TOPIC_ID"))

    message_id = publisher.publish(image_data, annotations)
    print(f"\nPublished detection log: {message_id}")


if __name__ == "__main__":
    main()
