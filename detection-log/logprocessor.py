from os import environ

import uvicorn

from detectionlog.logprocessor import create_app

app = create_app(environ["BUCKET_NAME"])


if __name__ == "__main__":
    config = uvicorn.Config("logprocessor:app",
                            host="0.0.0.0",
                            port=int(environ.get("PORT", "8080")),
                            log_level="info")
    server = uvicorn.Server(config)
    server.run()
