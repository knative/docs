# Sentiment Analysis Service for Bookstore Reviews

As a bookstore owner, you aim to receive instant notifications in a Slack channel whenever a customer submits a new **negative** review comment. By leveraging Knative Function, you can set up a serverless function that contains a simple sentiment analysis service to categorize review comments by sentiment.
## What Knative features will we learn about?

- The easiness to use **Knative Function** to deploy your service, and make it be managed by **Knative Serving**, which give you the ability to auto-scale your service to zero, and scale up to handle the demand.

## What does the final deliverable look like?
A running serverless Knative function that contains a python application that can receives the new review comments as CloudEvent and returns the sentiment classification of the input text as CloudEvent.

The function's output will be only from 
- Positive
- Neutral
- Negative
## Install Prerequisites

[//]: # (Warning box: please make sure you have a running cluster with Knative Eventing and Serving installed. If not, click here. And you have the container registry ready.)

### Prerequisite 1: Install Knative `func` CLI
Knative Function enables you to easily create, build, and deploy stateless, event-driven functions as [Knative Services](https://knative.dev/docs/serving/services/#:~:text=Knative%20Services%20are%20used%20to,the%20Service%20to%20be%20configured) by using the func CLI.

In order to do so, you need to install the `func` CLI.
You can follow the [official documentation](https://knative.dev/docs/getting-started/install-func/) to install the `func` CLI.

Running `func version` in your terminal to verify the installation, and you should see the version of the `func` CLI you installed.

## Implementation
The process is straightforward:
- Begin by utilizing the `func create` command to generate your code template.
- Next, incorporate your unique code into this template.
- Finally, execute `func deploy` to deploy your application seamlessly to the Kubernetes cluster.

This workflow ensures a smooth transition from development to deployment within the Knative Functions ecosystem.

[//]: # (Troubleshooting: if you see command not found, you may need to add the `func` CLI to your PATH.)
### Step 1: Create a Knative Function template

Create a new function using the `func` CLI:

```bash
func create -l <language> <function-name>
```

In this case, we are creating a python function, so the command will be:
   
```bash
func create -l python sentiment-analysis
```

This command will create a new directory with the name `sentiment-analysis` and a bunch of files in it. The `func` CLI will generate a basic function template for you to start with.

You can find all the supported languages templates [here](https://knative.dev/docs/functions/).

The file tree will look like this:
```bash
sentiment-analysis
├── func.yaml                 
├── .funcignore               
├── .gitignore                
├── requirements.txt         
├── app.sh
├── func.yaml
├── Procfile
└── func.py

```
### Step 2: Replace the generated code with the sentiment analysis logic 
`func.py` is the file that contains the code for the function. You can replace the generated code with the sentiment analysis logic. You can use the following code as a starting point:

```python title="func.py"
# parliament is a library that provides a simple way to interact with CloudEvents in Python.
from parliament import Context

from flask import Request,request, jsonify
import json

# Import the TextBlob library for sentiment analysis
from textblob import TextBlob
from time import sleep

# Import the CloudEvent and to_structured classes from the cloudevents package
from cloudevents.http import CloudEvent, to_structured


# The function to convert the sentiment analysis result into a CloudEvent
def create_cloud_event(data):
    # Put the sentiment into a JSON object
    sentiment = json.dumps({"result": data})

    attributes = {
    "type": "sentiment-analysis-result",
    "source": "sentiment-analysis-service",
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

```

### Step 3: Configure the dependencies
The `requirements.txt` file contains the dependencies for the function. You can add the following dependencies to the `requirements.txt` file:

```bash
Flask==3.0.2
textblob==0.18.0.post0
parliament-functions==0.1.0
cloudevents
```
Knative function will automatically install the dependencies listed here when you build the function.

### Step 4: Configre the pre-built environment
In order to properly use the `textblob` library, you need to download the corpora, which is a large collection of text data that is used to train the sentiment analysis model. You can do this by creating a new file called `setup.py`,
knative function will ensure that the `setup.py` file is executed after the dependencies have been installed.


The `setup.py` file should contain the following code for your bookstore:


```python
from setuptools import setup, find_packages
from setuptools.command.install import install
import subprocess


class PostInstallCommand(install):
    """Post-installation for installation mode."""
    def run(self):
        # Call the superclass run method
        install.run(self)
        # Run the command to download the TextBlob corpora
        subprocess.call(['python', '-m', 'textblob.download_corpora', 'lite'])


setup(
    name="download_corpora",
    version="1.0",
    packages=find_packages(),
    cmdclass={
        'install': PostInstallCommand,
    }
)
```




### Step 5: Try to build and run your Knative Function on your local machine

In knative function, there are two ways to build: using the [pack build](https://github.com/knative/func/blob/8f3f718a5a036aa6b6eaa9f70c03aeea740015b9/docs/reference/func_build.md?plain=1#L46) or using the [source-to-image (s2i) build](https://github.com/knative/func/blob/4f48549c8ad4dad34bf750db243d81d503f0090f/docs/reference/func_build.md?plain=1#L43). 

Currently. only the **s2i** build is supported if you need to run setup.py. When building with s2i, the `setup.py` file will be executed automatically after the dependencies have been installed.

Before we get started, configure the container registry to push the image to the container registry. You can use the following command to configure the container registry:

```bash
export FUNC_REGISTRY=<your-container-registry>
```

In this case, we will use the s2i build by adding the flag `-b=s2i`, and `-v` to see the verbose output.

```bash
func build -b=s2i -v
```

When the build is complete, you will see the following output:

```bash
🙌 Function built: <Your container registry username>/sentiment-analysis-app:latest
```

This command will build the function and push the image to the container registry. After the build is complete, you can run the function using the following command:

```bash
func run
```
In the future, you can skip the step of func build, because func run will automatically build the function for you.

You will see the following output if the function is running successfully:

```
function up-to-date. Force rebuild with --build
Running on host port 8080
---> Running application from script (app.sh) ...
````

Now you can test the function by sending a request to the function using the following command:

```bash
curl -X POST http://localhost:8080/ \
-H "ce-id: 12345" \
-H "ce-source: my-local" \
-H "ce-type: sentiment-analysis-request" \
-H "ce-specversion: 1.0" \
-H "Content-Type: application/json" \
-d '{"input": "I love Knative so much!"}'
```

If the function is running successfully, you will see the following output:

```bash
{
  "data": {
    "result": "{\"result\": \"Positive\"}"
  },
  "id": "7b774892-f989-4252-a6b2-f2923a6c8246",
  "source": "sentiment-analysis",
  "specversion": "1.0",
  "time": "2024-02-31T18:42:52.096270+00:00",
  "type": "knative.sampleapp.sentiment.response"
}

```

### Step 6: Deploy the function to the cluster
After you have finished the code, you can deploy the function to the cluster using the following command:

```bash
func deploy -b=s2i -v
```

When the deployment is complete, you will see the following output:

```bash
🙌 Deployed function: <Your container registry username>/sentiment-analysis-app:latest
```

### Step 7: Verify the Deployment
After deployment, the `func` CLI provides a URL to access your function. You can verify the function's operation by sending a request with a sample review comment.

But directly sending CloudEvents to a Knative service using curl from an external machine (like your local computer) is typically **constrained** due to the networking and security configurations of Kubernetes clusters.

Therefore, you need to create a new pod in your Kubernetes cluster to send a CloudEvent to the Knative Function service. You can use the following command to create a new pod:

```bash
$ kubectl run curler --image=radial/busyboxplus:curl -it --restart=Never
```
You will see this message if you successfully entered the pod's shell

```
If you don't see a command prompt, try pressing enter.
[root@curler:/]$ 
```


Using curl command to send a CloudEvent to the broker:
```bash
[root@curler:/]$ curl -v "<The URI to your Knative Function>" \
-X POST \
-H "ce-id: 12345" \
-H "ce-source: my-local" \
-H "ce-type: sentiment-analysis-request" \
-H "ce-specversion: 1.0" \
-H "Content-Type: application/json" \
-d '{"input": "I love Knative so much! Sent to the cluster"}'
```

Expect to receive a JSON response indicating the sentiment classification of the input text.

```bash
{
  "data": {
    "result": "{\"result\": \"Positive\"}"
  },
  "id": "7b774892-f989-4252-a6b2-f2923a6c8246",
  "source": "sentiment-analysis",
  "specversion": "1.0",
  "time": "2024-02-31T18:42:52.096270+00:00",
  "type": "knative.sampleapp.sentiment.response"
}
```
If you see the response, it means that the function is running successfully.
Congratulations! You have successfully set up the sentiment analysis service for your bookstore.

## Conclusion

In this tutorial, you learned how to create a serverless function that contains a simple sentiment analysis service with Knative function.