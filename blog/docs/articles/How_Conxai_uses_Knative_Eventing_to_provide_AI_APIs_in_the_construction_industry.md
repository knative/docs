# How CONXAI uses Knative Eventing to provide AI APIs in the construction industry

**Author: Tim Krause, Lead MLOps Architect @ CONXAI**

[CONXAI Technologies GmbH](https://www.conxai.com/) is an AI startup in the construction industry. Our fine-tuned model with thousands of labeled images from construction sites achieves significantly greater accuracy than other MaaS (Model-as-a-Service) offerings. In this blog post, we highlight a use case where our solution blurs people's bodies in CCTV camera images, ensuring GDPR compliance.

## Why we use Knative Eventing

On the one hand, at CONXAI we decided very early to use primarily Kubernetes for our processing to maintain cloud agnosticism. Our idea is to ship our services to the customer's edge in the future. Furthermore, Kubernetes gives us a lot of flexibility. However, we value managed services, particularly for data handling, to operate efficiently as a young startup. That's why we are tightly integrated with AWS.

On the other hand, our AI team has limited experience with cloud, infrastructure and Kubernetes. So we looked into proper abstractions to make it easy for everyone to adopt the cloud and its scalability. Knative provides a declarative, yet standardized approach by offering Custom Resource Definitions for the main building blocks.

## Why we use KServe for our AI model

KServe is a standard Model Inference Platform on Kubernetes that leverages Knative Serving as its foundation and is fully compatible with Knative Eventing. It also pulls models from a model repository into the container before the model server starts, eliminating the need to build a new container image for each model version. The next section explains how we use Knative Eventing and KServe for our blurring product.

## Our blurring product step by step

First, the customer uploads an image to be blurred via our API, which saves the image on S3. The S3 event is routed to our AWS EventBridge. The TriggerMesh AWSEventBridgeSource automatically configures an Amazon SQS queue and EventBridge Rule to forward the S3 event into that Amazon SQS queue. Because TriggerMesh has been deprecated, we will switch to Knative Serving [IntegrationSource](https://knative.dev/blog/articles/consuming_sqs_data_with_integrationsource/) approach with AWS SQS in the future. Then it passes that event into the Knative Broker which is backed by Amazon MSK - Kafka. Since we heavily rely on S3 key/file names, we wrote our own router service in Golang which modifies the EventType using regex patterns and sends it back to the Knative Broker.

Another Knative Trigger moves it into our transformer which handles preprocessing first. As the next step, the transformer calls the predictor (Nvidia Triton) directly over HTTP. We use the KServe "Collocate transformer and predictor in same pod" [feature](https://kserve.github.io/website/0.13/modelserving/v1beta1/transformer/collocation/) to maximize inference speed and throughput. After receiving model results, the transformer does the postprocessing and finally saves the model results on S3.

The last Knative Trigger forwards the model results event into a masker service written in Rust to blur all people and saves that blurred image on S3. Finally, the customer polls our initial API periodically and retrieves the blurred image when available on S3.

## Knative Eventing benefits

This eventing architecture has numerous benefits. It can handle bursts, it decouples microservices to ship a new version with small increments and it is easy to develop and debug by imitating CloudEvents even locally. The Dead Letter Sink (DLQ) supports long-term problem resolution.
On an organization level, all developers feel comfortable with paradigms and infrastructure across different projects and products.

In this blog article, we just highlighted one specific use case, but we use Knative Eventing extensively across our projects and products.
