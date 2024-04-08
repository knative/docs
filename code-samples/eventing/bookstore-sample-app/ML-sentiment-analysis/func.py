from parliament import Context
from flask import Request,request, jsonify
import json
from textblob import TextBlob
from time import sleep
from cloudevents.http import CloudEvent, to_structured

# The function to convert the sentiment analysis result into a CloudEvent
def create_cloud_event(inputText,data):
    attributes = {
    "type": "knative.sampleapp.sentiment.response",
    "source": "sentiment-analysis",
    "datacontenttype": "application/json",
    }

    # Put the sentiment analysis result into a dictionary
    data = {
    "input": inputText,
    "result": data
    }

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event

def analyze_sentiment(text):
   analysis = TextBlob(text["input"])
   sentiment = "Neutral"
   if analysis.sentiment.polarity > 0:
       sentiment = "Positive"
   elif analysis.sentiment.polarity < 0:
       sentiment = "Negative"

   # Convert the sentiment into a CloudEvent
   sentiment = create_cloud_event(text["input"],sentiment)

   return sentiment

def main(context: Context):
    """ 
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    print("Received CloudEvent: ", context.cloud_event)

    # Add your business logic here
    return analyze_sentiment(context.cloud_event.data)
