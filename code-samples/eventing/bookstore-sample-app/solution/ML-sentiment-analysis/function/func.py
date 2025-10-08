import logging
from cloudevents.http import CloudEvent
from textblob import TextBlob
import textblob

def new():
    return Function()


class Function:
    async def handle(self, scope, receive, send):
        """ Handle all HTTP requests to this Function. The incoming CloudEvent is in scope["event"]. """
        logging.info("Request Received")

        # 1. Get the incoming CloudEvent
        request_event = scope["event"]

        # 2. Extract the data payload from the event, analyze and create CloudEvent
        response_event = self.analyze_sentiment(request_event.data)

        # 3. Send the response
        logging.info(f"Sending response: {response_event.data}")
        await send(response_event)

    def create_cloud_event(self, inputText, badWordResult, data):
        attributes = {
            "type": "moderated-comment",
            "source": "sentiment-analysis",
            "datacontenttype": "application/json",
            "sentimentResult": data,
            "badwordfilter": badWordResult,
        }

        # Put the sentiment analysis result into a dictionary
        data = {
            "reviewText": inputText,
            "badWordResult": badWordResult,
            "sentimentResult": data,
        }

        return CloudEvent(attributes, data)

    def analyze_sentiment(self, text):
        review_text = text.get("reviewText", "")
        analysis = TextBlob(review_text)
        sentiment = "neutral"

        if analysis.sentiment.polarity > 0:
            sentiment = "positive"
        elif analysis.sentiment.polarity < 0:
            sentiment = "negative"

        badWordResult = ""
        try:
            badWordResult = text["badWordResult"]
        except KeyError:
            pass

        # Convert the sentiment into a CloudEvent
        return self.create_cloud_event(review_text, badWordResult, sentiment)

