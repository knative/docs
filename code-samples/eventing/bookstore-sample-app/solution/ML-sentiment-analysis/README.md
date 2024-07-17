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

---
(Warning box: please make sure you have a running cluster with Knative Eventing and Serving installed. If not, click here. And you have the container registry ready.)

---

### Prerequisite 1: Install Knative `func` CLI
Knative Function enables you to easily create, build, and deploy stateless, event-driven functions as [Knative Services](https://knative.dev/docs/serving/services/#:~:text=Knative%20Services%20are%20used%20to,the%20Service%20to%20be%20configured){:target="_blank"} by using the func CLI.

In order to do so, you need to install the `func` CLI.
You can follow the [official documentation](https://knative.dev/docs/getting-started/install-func/){:target="_blank"} to install the `func` CLI.

Running `func version` in your terminal to verify the installation, and you should see the version of the `func` CLI you installed.

## Implementation
The process is straightforward:
- Begin by utilizing the `func create` command to generate your code template.
- Next, incorporate your unique code into this template.
- Finally, execute `func deploy` to deploy your application seamlessly to the Kubernetes cluster.

This workflow ensures a smooth transition from development to deployment within the Knative Functions ecosystem.

---
a warning box:
(Troubleshooting: if you see `command not found`, you may need to add the `func` CLI to your PATH.)
---
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

You can find all the supported languages templates [here](https://knative.dev/docs/functions/){:target="_blank"}.

The file tree will look like this:
```bash
sentiment-analysis
├── func.yaml                 
├── .funcignore               
├── .gitignore                
├── requirements.txt         
├── app.sh
├── Procfile
└── func.py

```
### Step 2: Replace the generated code with the sentiment analysis logic 
`func.py` is the file that contains the code for the function. You can replace the generated code with the sentiment analysis logic. You can use the following code as a starting point:

```python title="func.py"
from parliament import Context
from flask import Request,request, jsonify
import json
from textblob import TextBlob
from time import sleep
from cloudevents.http import CloudEvent, to_structured

# The function to convert the sentiment analysis result into a CloudEvent
def create_cloud_event(data):
    attributes = {
    "type": "knative.sampleapp.sentiment.response",
    "source": "sentiment-analysis",
    "datacontenttype": "application/json",
    }
    
    # Put the sentiment analysis result into a dictionary
    data = {"result": data}

    # Create a CloudEvent object
    event = CloudEvent(attributes, data)

    return event

def analyze_sentiment(text):
   analysis = TextBlob(text)
   sentiment = "Neutral"
   if analysis.sentiment.polarity > 0:
       sentiment = "Positive"
   elif analysis.sentiment.polarity < 0:
       sentiment = "Negative"

   # Convert the sentiment into a CloudEvent
   sentiment = create_cloud_event(sentiment)

   # Sleep for 3 seconds to simulate a long-running process
   sleep(3)

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

```

### Step 3: Configure the dependencies
The `requirements.txt` file contains the dependencies for the function. You can add the following dependencies to the `requirements.txt` file:

```bash
Flask==3.0.2
textblob==0.18.0.post0
parliament-functions==0.1.0
cloudevents==1.10.1
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

In knative function, there are two ways to build: using the [pack build](https://github.com/knative/func/blob/8f3f718a5a036aa6b6eaa9f70c03aeea740015b9/docs/reference/func_build.md?plain=1#L46){:target="_blank"} or using the [source-to-image (s2i) build](https://github.com/knative/func/blob/4f48549c8ad4dad34bf750db243d81d503f0090f/docs/reference/func_build.md?plain=1#L43){:target="_blank"}. 

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

---
An alert box
Issue you may experience:
```
Error: '/home/Kuack/Documents/knative/docs/code-samples' does not contain an initialized function
```
Solution: You may want to check whether you are in the correct directory. You can use the following command to check the current directory.


If you are in the right directory, and the error still occurs, try to check your func.yaml,

as it has to contain the field `created` and the right time stamp to be treated as a valid knative function.

---

```bash
func run -b=s2i -v
```
In the future, you can **skip the step of `func build`**, because func run will automatically build the function for you.

You will see the following output if the function is running successfully:

```
function up-to-date. Force rebuild with --build
Running on host port 8080
---> Running application from script (app.sh) ...
````

Now you can test the function by sending a request to the function using the following command:

```bash
curl -X POST http://localhost:8080 \
-H "ce-id: 12345" \
-H "ce-source: /your/source" \
-H "ce-type: sentiment-analysis-request" \
-H "ce-specversion: 1.0" \
-H "Content-Type: application/json" \
-d '{"input":"I love Knative so much!"}'
```
where `-H` are the headers, and `-d` is the input text. The input text is a **sting**. Be careful with the quotes.

If the function is running successfully, you will see the following output (the `data` field in the Response CloudEvent only):

```bash
{
  "input":"I love Knative so much!",
  "result": "Positive"
}
```

Knative function also have an easy way to simulate the CloudEvent, you can use the following command to simulate the CloudEvent:

```bash
func invoke -f=cloudevent --data='{"input": "I love Knative so much"}' --content-type=application/json --type="new-comment" -v 
```
where the `-f` flag indicates the type of the data, is either `HTTP` or `cloudevent`, and the `--data` flag is the input text.
You can read more about `func invoke` [here](https://github.com/knative/func/blob/main/docs/reference/func_invoke.md){:target="_blank"}.

In this case, you will get the full CloudEvent response:

```bash
Context Attributes,
  specversion: 1.0
  type: knative.sampleapp.sentiment.response
  source: sentiment-analysis
  id: af0c0f59-9130-4a6c-96ef-6d72c2f4ce50
  time: 2024-02-31T18:48:00.232436Z
  datacontenttype: application/json
Data,
  {
    "input":"I love Knative so much!",
    "result": "Positive"
  }

```

### Step 6: Deploy the function to the cluster
After you have finished the code, you can deploy the function to the cluster using the following command:

```bash
func deploy -b=s2i -v
```

When the deployment is complete, you will see the following output:

```bash
✅ Function updated in namespace "default" and exposed at URL: 
   http://sentiment-analysis-app.default.10.99.46.8.sslip.io
```

You can also find the URL by running the following command:

```bash
kubectl get kservice -A 
```

You will see the URL in the output:

```bash
NAMESPACE   NAME                     URL                                                       LATESTCREATED                  LATESTREADY                    READY   REASON
default     sentiment-analysis-app   http://sentiment-analysis-app.default.10.99.46.8.sslip.io   sentiment-analysis-app-00002   sentiment-analysis-app-00002   True    
```

Please note: if your URL ends with .svc.cluster.local, that means you can only access the function from within the cluster. You probably forget to configure the network or [start the tunnel](https://knative.dev/docs/getting-started/quickstart-install/#__tabbed_3_2){:target="_blank"} if you are using minikube.

### Step 7: Verify the Deployment
After deployment, the `func` CLI provides a URL to access your function. You can verify the function's operation by sending a request with a sample review comment.

Simply use Knative function's command `func invoke` to directly send a CloudEvent to the function on your cluster:

```bash
func invoke -f=cloudevent --data="i love knative community so much" -v -t="http://sentiment-analysis-app.default.10.99.46.8.sslip.io"
```

- `-f` flag indicates the type of the data, is either `HTTP` or `cloudevent`
- `--data` flag is the input text
- `-t` flag is the URI to the Knative Function.

If the function is running successfully, you will see the following output:

```bash
Context Attributes,
  specversion: 1.0
  type: knative.sampleapp.sentiment.response
  source: sentiment-analysis
  id: 6a246e0c-2b24-4f22-93c4-f1265c569b2d
  time: 2024-02-31T19:03:50.434822Z
  datacontenttype: application/json
Data,
  {
    "input":"I love Knative so much!",
    "result": "Positive"
  }
```

---
Recall note box: you can get the URL to the function by running the following command:
```bash
kubectl get kservice -A 
```
---
Another option is to use curl to send a CloudEvents to the function.
Using curl command to send a CloudEvents to the Broker:
```bash
[root@curler:/]$ curl -v "http://sentiment-analysis-app.default.10.99.46.8.sslip.io" \
-X POST \
-H "ce-id: 12345" \
-H "ce-source: my-local" \
-H "ce-type: sentiment-analysis-request" \
-H "ce-specversion: 1.0" \
-H "Content-Type: application/json" \
-d '"I love Knative so much! Sent to the cluster"'
```

Expect to receive a JSON response indicating the sentiment classification of the input text.

```bash
{
  "input":"I love Knative so much!",
  "result": "Positive"
}
```
If you see the response, it means that the function is running successfully.

---
### The magic time about Serverless: autoscaling to zero
If you use the following command to query all the pods in the cluster, you will see that the pod is running:

```bash
kubectl get pods -A
```
where `-A` is the flag to query all the pods in all namespaces.

And you will find that your sentiment analysis app is running:

```bash
NAMESPACE   NAME                                        READY   STATUS    RESTARTS   AGE
default     sentiment-analysis-app-00002-deployment    2/2     Running   0          2m
```

But if you wait for a while without sending any CloudEvent to your function, and query the pods again, you will find that the pod that has your sentiment analysis app **disappeared**!


This is because **Knative Serving's autoscaler** will automatically scale down to zero if there is no request to the function!

---

Congratulations! You have successfully set up the sentiment analysis service for your bookstore.

## Conclusion

In this tutorial, you learned how to create a serverless function that contains a simple sentiment analysis service with Knative function.