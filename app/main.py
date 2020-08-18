import logging
import os
import sys
import traceback

from fastapi import FastAPI
from fastapi.logger import logger
from fastapi.responses import JSONResponse, Response

from starlette.middleware.base import RequestResponseEndpoint
from starlette.requests import Request

from .libs.database import client as db
from .libs.logging import JsonFormatter
from .routers import router

DB_HOST = os.environ["DB_HOST"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_NAME = os.environ["DB_NAME"]
APP_LOG_LEVEL = os.getenv("APP_LOG_LEVEL", "INFO")

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger.addHandler(handler)
logger.setLevel(APP_LOG_LEVEL)

app = FastAPI()
app.include_router(router, prefix="/v1")


@app.on_event("startup")
async def db_startup() -> None:
    await db.init(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        db=DB_NAME,
    )
    logger.info("DB client successfully connected.")


@app.on_event("shutdown")
async def db_shutdown() -> None:
    await db.close()
    logger.info("DB client successfully closed.")


@app.middleware("http")
async def error_logging_middleware(
    request: Request,
    call_next: RequestResponseEndpoint,
) -> Response:
    try:
        return await call_next(request)
    except Exception:
        try:
            body = (await request.body()).decode()
        except Exception as e:
            body = f"args: {str(e.args)}, e: {str(e)}"
        trace = "".join(traceback.format_exception(*sys.exc_info()))
        logger.error(
            {
                "client_ip": request.client.host,
                "path": request.url.path,
                "method": request.method,
                "query": request.url.query,
                "body": body,
                "traceback": trace,
            }
        )
        return JSONResponse({"detail": "Internal Server Error"}, status_code=500)


@app.get("/heartbeat", include_in_schema=False)
def heartbeat():
    return {"status": "OK"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
