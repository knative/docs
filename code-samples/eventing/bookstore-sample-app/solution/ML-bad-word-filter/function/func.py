import logging
from cloudevents.http import CloudEvent
from profanity_check import predict

def new():
    return Function()

class Function:
    async def handle(self, scope, receive, send):
        """ Handle all HTTP requests to this Function. The incoming CloudEvent is in scope["event"]. """
        logging.info("Request Received")

        # 1. Extract the CloudEvent from the scope
        request_event = scope["event"]

        # 2. Extract the data payload from the event, analyze and create CloudEvent
        response_event = self.inappropriate_language_filter(request_event.data)

        # 3. Send the response
        logging.info(f"Sending response: {response_event.data}")
        await send(response_event)

    def create_cloud_event(self, inputText, data):
        attributes = {
            "type": "new-review-comment",
            "source": "book-review-broker",
            "datacontenttype": "application/json",
            "badwordfilter": data,
        }

        # Put the bad word filter result into a dictionary
        data = {"reviewText": inputText, "badWordResult": data}

        # Create a CloudEvent object
        return CloudEvent(attributes, data)

    def inappropriate_language_filter(self, text):
        review_text = text.get("reviewText", "")
        profanity_result = predict([review_text])
        result = "good"
        if profanity_result[0] == 1:
            result = "bad"

        return self.create_cloud_event(review_text, result)
