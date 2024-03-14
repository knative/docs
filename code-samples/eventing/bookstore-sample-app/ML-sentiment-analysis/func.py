from parliament import Context
from flask import Request,request, jsonify
import json
from textblob import TextBlob
from time import sleep
from cloudevents.http import CloudEvent, to_structured


# The function to convert the sentiment analysis result into a CloudEvent
def create_cloud_event(data):
    # Put the sentiment into a JSON object
    sentiment = json.dumps({"result": data})

    attributes = {
    "type": "knative.sampleapp.sentiment.response",
    "source": "sentiment-analysis",
    }
    data = {"result": sentiment}

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event

def analyze_sentiment(data):
   text = data['input']
   analysis = TextBlob(text)
   sentiment = "Neutral"
   if analysis.sentiment.polarity > 0:
       sentiment = "Positive"
   elif analysis.sentiment.polarity < 0:
       sentiment = "Negative"

    # Convert the sentiment into a CloudEvent
   sentiment = create_cloud_event(sentiment)

    # serialize the CloudEvent to a structured JSON object, the returned value is binary
   headers, body = to_structured(sentiment)

   # Sleep for 3 seconds to simulate a long-running process
   sleep(3)

    # Return the sentiment as a JSON object
   body_json = json.loads(body.decode())
   return body_json

def main(context: Context):
    """ 
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    # Add your business logic here
    return analyze_sentiment(context.cloud_event.data), 200
