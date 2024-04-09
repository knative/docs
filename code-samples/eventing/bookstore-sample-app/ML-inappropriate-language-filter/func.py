from parliament import Context
from profanity_check import predict
from cloudevents.http import CloudEvent

def create_cloud_event(data):
    attributes = {
        "type": "knative.sampleapp.inappropriate-language-filter.response",
        "source": "inappropriate-language-filter",
        "datacontenttype": "application/json",
    }

    # Put the inappropriate language filter result into a dictionary
    data = {"result": data}

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event

def inappropriate_language_filter(text: str | None):
    profanity_result = predict([text])
    result = "good"
    if profanity_result[0] == 1:
        result = "bad"

    profanity_event = create_cloud_event(result)
    return profanity_event

def main(context: Context):
    """
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    # Add your business logic here
    return inappropriate_language_filter(context.request.args.get("text"))
