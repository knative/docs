"""
Unit tests for the CloudEvent function implementation.
Tests both the function health endpoints and its handling of CloudEvents.

Functions are currently served as ASGI applications using hypercorn, so we
use httpx for testing.  To run the tests using poetry:

poetry run python -m unittest discover
"""
import json
import asyncio
import pytest
from cloudevents.http import CloudEvent
from function import new


@pytest.mark.asyncio
async def test_func():
    f = new()  # Instantiate Function to Test

    # A test CloudEvent
    attributes = {
        "id": "test-id",
        "type": "com.example.test1",
        "source": "https://example.com/event-producer",
    }
    data = {"message": "test message"}
    event = CloudEvent(attributes, data)

    invoked = False  # Flag indicating send method was invoked

    # Send
    # confirms the Functions responds with a CloudEvent which echoes
    # the data sent.
    async def send(e):
        nonlocal invoked
        invoked = True  # Flag send was invoked

        # Ensure we got a CloudEvent
        assert isinstance(e, CloudEvent), f"Expected CloudEvent, got {type(e)}"

        # Ensure it echoes the data sent
        assert e.data == data, f"Expected data {data}, got {e.data}"

    # Invoke the Function
    scope = {"event": event}  # Add the CloudEvent to the scope
    await f.handle(scope, {}, send)

    # Assert send was called
    assert invoked, "Function did not call send"
