from parliament import Context
from profanity_check import predict
from cloudevents.http import CloudEvent


# The function to convert the bad word filter result into a CloudEvent
def create_cloud_event(inputText, data):
    attributes = {
        "type": "new-review-comment",
        "source": "book-review-broker",
        "datacontenttype": "application/json",
        "badwordfilter": data,
    }

    # Put the bad word filter result into a dictionary
    data = {"reviewText": inputText, "badWordResult": data}

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event


def inappropriate_language_filter(text):
    profanity_result = predict([text["reviewText"]])
    result = "good"
    if profanity_result[0] == 1:
        result = "bad"

    profanity_event = create_cloud_event(text["reviewText"], result)
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
