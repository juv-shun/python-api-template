import pytest

from starlette.testclient import TestClient

from ..main import app


@pytest.fixture(scope='module')
def client():
    with TestClient(app) as client:
        yield client


def test_hello(client: TestClient):
    actual = client.get("/v1/")
    assert actual.status_code == 200
    assert actual.json() == {"message": "Hello World"}
