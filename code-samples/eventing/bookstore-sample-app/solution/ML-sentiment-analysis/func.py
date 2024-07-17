from parliament import Context
from flask import Request, request, jsonify
import json
from textblob import TextBlob
from time import sleep
from cloudevents.http import CloudEvent, to_structured


# The function to convert the sentiment analysis result into a CloudEvent
def create_cloud_event(inputText, badWordResult, data):
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

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event


def analyze_sentiment(text):
    analysis = TextBlob(text["reviewText"])
    sentiment = "neutral"
    if analysis.sentiment.polarity > 0:
        sentiment = "positive"
    elif analysis.sentiment.polarity < 0:
        sentiment = "negative"

    badWordResult = ""
    try:
        badWordResult = text["badWordResult"]
    except:
        pass
    # Convert the sentiment into a CloudEvent
    sentiment = create_cloud_event(text["reviewText"], badWordResult, sentiment)

    return sentiment


def main(context: Context):
    """
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    print("Sentiment Analysis Received CloudEvent: ", context.cloud_event)

    # Add your business logic here
    return analyze_sentiment(context.cloud_event.data)
