from parliament import Context
from flask import Request,request, jsonify
import json
from textblob import TextBlob
from time import sleep

def analyze_sentiment(data):
   text = data['input']
   analysis = TextBlob(text)
   sentiment = "Neutral"
   if analysis.sentiment.polarity > 0:
       sentiment = "Positive"
   elif analysis.sentiment.polarity < 0:
       sentiment = "Negative"

    # Put the sentiment into a JSON object
    sentiment = json.dumps({"result": sentiment})

    # Sleep for 5 seconds to simulate a long-running process
    sleep(3)
   return sentiment

def main(context: Context):
    """ 
    Function template
    The context parameter contains the Flask request object and any
    CloudEvent received with the request.
    """

    # Add your business logic here
    return analyze_sentiment(context.cloud_event.data), 200
