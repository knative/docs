from cloudevents.core.bindings.http import HTTPMessage, from_http_event, to_binary_event
from cloudevents.core.exceptions import BaseCloudEventException
from cloudevents.core.v1.event import CloudEvent
from flask import Flask, request

app = Flask(__name__)


@app.post("/")
def hello_world():
    try:
        event = from_http_event(HTTPMessage(dict(request.headers), request.get_data()))
    except (BaseCloudEventException, ValueError) as error:
        return {"error": str(error)}, 400

    app.logger.warning("Event received: %s", event.get_data())
    reply = CloudEvent(
        {
            "type": "dev.knative.samples.hifromknative",
            "source": "knative/eventing/samples/hello-world",
            "datacontenttype": "application/json",
        },
        {"msg": "Hi from helloworld-python app!"},
    )
    message = to_binary_event(reply)
    return message.body, 200, message.headers
