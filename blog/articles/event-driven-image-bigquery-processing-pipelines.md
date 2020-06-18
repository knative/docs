---
title: "Event-driven Image and BigQuery processing pipelines with Knative"
linkTitle: "Event-driven image and BigQuery processing pipelines with Knative"
date: 2020-06-19
description: "Using Knative Eventing to build event-driven image and BigQuery
processing pipelines"
type: "blog"
---

In this blog post, I will outline two event-driven processing pipelines that I
recently built with Knative Eventing. Along the way, I will explain event sources,
custom events and other components provided by Knative, that greatly simplify the
development of event-driven architectures.

Both of these pipelines are available on GitHub, including source code, configurations, and detailed
instructions, as part of my [Knative Tutorial](https://github.com/meteatamel/knative-tutorial).

## Image Processing Pipeline

This is an image processing pipeline where users upload an image to a storage
bucket on Google Cloud, get the image processed with a number of different Knative
services and the processed images are saved to an output bucket.

I had 2 main requirements:

1. Uploaded images are filtered (eg. no adult or violent images) before sending
   through the pipeline.
2. Pipeline can contain any number of processing services that can be added or
   removed as needed.

### Architecture

Here's the architecture of the image processing pipeline. It's deployed to
Google Kubernetes Engine (GKE) on Google Cloud:

![Image processing pipeline architecture](https://atamel.dev/img/2020/image-processing-pipeline.png)

1. An image is saved to an input Cloud Storage bucket.
2. Cloud Storage update event is read into Knative by
   [CloudStorageSource](https://github.com/google/knative-gcp/blob/master/docs/examples/cloudstoragesource/README.md).
3. Filter service receives the Cloud Storage event. It uses Vision API to
   determine if the image is safe. If so, it creates a custom `CloudEvent` of
   type `dev.knative.samples.fileuploaded` and passes it back to `Broker`.
4. Resizer service receives the `fileuploaded` event, resizes the image using
   [ImageSharp](https://github.com/SixLabors/ImageSharp) library, saves to the
   resized image to the output bucket, creates a custom `CloudEvent` of type
   `dev.knative.samples.fileresized` and passes the event back to `Broker`.
5. Watermark service receives the `fileresized` event, adds a watermark to the
   image using [ImageSharp](https://github.com/SixLabors/ImageSharp) library and
   saves the image to the output bucket.
6. Labeler receives the `fileuploaded` event, extracts labels of the image with
   Vision API and saves the labels to the output bucket.

### Test the pipeline

To test the pipeline, I upload the following picture from my favorite beach
(Ipanema in Rio de Janeiro) to the bucket:

![Beach with sunset](https://atamel.dev/img/2020/beach.jpg)

After a few seconds, I see 3 files in my output bucket:

```sh
gsutil ls gs://knative-atamel-images-output

gs://knative-atamel-images-output/beach-400x400-watermark.jpeg
gs://knative-atamel-images-output/beach-400x400.png
gs://knative-atamel-images-output/beach-labels.txt
```

We can see the labels `Sky,Body of
water,Sea,Nature,Coast,Water,Sunset,Horizon,Cloud,Shore` in the text file and
the following resized and watermarked image:

![Beach with sunset](https://atamel.dev/img/2020/beach-400x400-watermark.jpeg)

## BigQuery Processing Pipeline

In this second pipeline, I built a schedule driven pipeline. In this pipeline, I query
find the daily COVID-19 cases for a couple of countries. I use a public COVID-19
dataset on BigQuery to get the data, generate some charts and send myself an
email for each country once a day with those charts.

### Architecture

Here's the architecture of the pipeline.

![BigQuery processing pipeline architecture](https://atamel.dev/img/2020/bigquery-processing-pipeline.png)

1. Two `CloudSchedulerSources` are setup for two countries (United Kingdom and
   Cyprus) to call the `QueryRunner` service once a day.
2. `QueryRunner` service written in C#. It receives the scheduler event for both
   countries, queries Covid-19 cases for the country using BigQuery's public
   Covid-19 dataset and saves the result in a separate BigQuery table. Once
   done, `QueryRunner` returns a custom `CloudEvent` of type
   `dev.knative.samples.querycompleted`.
3. `ChartCreator` service written in Python. It receives the `querycompleted`
   event, creates a chart from BigQuery data using `Matplotlib` and saves it to
   a Cloud Storage bucket.
4. `Notifier` is another Python service that receives the
   `com.google.cloud.storage.object.finalize` event from the bucket via a
   `CloudStorageSource` and sends an email notification to users using SendGrid.

### Test the pipeline

`CloudSchedulerSource` creates `CloudScheduler` Jobs under the covers:

```bash
gcloud scheduler jobs list

ID                                                  LOCATION      SCHEDULE (TZ)          TARGET_TYPE  STATE
cre-scheduler-2bcb33d8-3165-4eca-9428-feb99bc320e2  europe-west1  0 16 * * * (UTC)       Pub/Sub      ENABLED
cre-scheduler-714c0b82-c441-42f4-8f99-0e2eac9a5869  europe-west1  0 17 * * * (UTC)       Pub/Sub      ENABLED
```

And you can trigger them on demand:

```bash
gcloud scheduler jobs run cre-scheduler-2bcb33d8-3165-4eca-9428-feb99bc320e2
```

You should get an email with with a chart similar to this in a few minutes:

![Chart - United Kingdom](https://atamel.dev/img/2020/chart-unitedkingdom.png)

## Knative Goodness

In these pipelines, I relied on a few Knative components that greatly simplified
my development. More specifially:

1. [Eventing Sources](https://knative.dev/docs/eventing/sources/) allow you to
   read external events in your cluster and [Knative-GCP
   Sources](https://github.com/google/knative-gcp#knative-gcp-sources) provide a
   number of eventing sources ready to read events from various Google Cloud
   sources.
2. [Broker and Trigger](https://knative.dev/docs/eventing/broker/) provide an
   eventing backbone where right events are delivered to right event consumers
   without producers or consumers having to know about how the events are routed.
3. **Custom events and event replies**: In Knative, all events are
   [CloudEvents](https://cloudevents.io/), so it's useful to have a standard format
   for events and various SDKs to read/write them. Knative supports
   custom events and event replies. Any service can receive an event, do some
   processing, create a custom event with new data, and reply back to the broker
   so that other services can read the custom event. This is useful in pipelines,
   where each service does a little bit of work and passes the message forward to the next service.

This wraps up my post. As I already mentioned, if you want more detailed instructions,
you can check out
[image-processing-pipeline](https://github.com/meteatamel/knative-tutorial/blob/master/docs/image-processing-pipeline.md)
and
[bigquery-processing-pipeline](https://github.com/meteatamel/knative-tutorial/blob/master/docs/bigquery-processing-pipeline.md)
as part of my [Knative Tutorial](https://github.com/meteatamel/knative-tutorial)

If you have questions/comments, feel free to reach out to me on Twitter [@meteatamel](https://twitter.com/meteatamel)).

---

By [Mete Atamel](https://twitter.com/meteatamel) - Developer Advocate, Google Cloud
