from parliament import Context
from profanity_check import predict
from cloudevents.http import CloudEvent

# The function to convert the bad word filter result into a CloudEvent
def create_cloud_event(inputText,data):
    attributes = {
    "type": "knative.sampleapp.badword.filter.response",
    "source": "bad-word-filter",
    "datacontenttype": "application/json",
    }

    # Put the bad word filter result into a dictionary
    data = {
    "input": inputText,
    "result": data
    }

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event

def inappropriate_language_filter(text):
    profanity_result = predict([text["input"]])
    result = "good"
    if profanity_result[0] == 1:
        result = "bad"

    profanity_event = create_cloud_event(text["input"],result)
    return profanity_event

def main(context: Context):
    """
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    print("Received CloudEvent: ", context.cloud_event)

    # Add your business logic here
    return inappropriate_language_filter(context.cloud_event.data)
