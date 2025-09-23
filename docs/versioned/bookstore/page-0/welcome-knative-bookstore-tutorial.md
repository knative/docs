# Welcome: Knative Bookstore Tutorial

![Welcome Image](images/1.png)

**Welcome to Knative's End-to-End Sample Application Tutorial!**

- Are you completely new to Knative and unsure where to start?
- Are you considering converting your application to an event-driven architecture but don't know how?
- Are you curious to see what Knative can do in real life?
- Are you new to the cloud computing world and looking to get started with open source?

!!! success "You found the right place"

    If any of these resonate with you, you've found the perfect starting point.

In this tutorial, we will construct an online bookstore application. This interactive guide, suitable for beginners and experienced engineers alike, will take you through the steps of building, deploying, and monitoring an application using Knative's powerful features. For those familiar with the process, concise graphics are available to streamline your learning experience.

## **What are we building?**

![App Diagram](images/2.png)

Our App is an online bookstore that sells a single book. Customers can post comments about the book anonymously, with each comment displayed alongside an emoji reflecting the sentiment of the comment. Comments with inappropriate content are automatically filtered out, discarded, and logged in the backend.

As the bookstore owner, you'll receive notifications via Slack each time if a comment containing a "bad word" is submitted.

## **Learning Goal**

![Learning Goal Image](images/3.png)

You will learn Event-Driven Architecture (EDA) and how it contrasts with traditional application designs that use microservices and REST APIs. You'll learn:

- **The Fundamentals of EDA**: Explore the core principles of event-driven architecture and how it enhances responsiveness and scalability in applications.
- **Comparative Insights**: Understand the differences between EDA and traditional architectures, highlighting the benefits and use cases of each.
- **Practical Application**: Discover how to transition your existing applications to an event-driven model, utilizing the powerful features of Knative Eventing.

![Knative Framework](images/4.png)

Knative is a powerful framework that operates on top of Kubernetes. This tutorial will guide you through:

- **Setting Up Your Cluster**: You'll start by spinning up your own Kubernetes cluster, which is the foundation for deploying and managing containers.
- **Exploring Knative**: Gain hands-on experience with key Knative concepts and components.
- **Some example use cases of Knative**.

By the end of this tutorial, you will not only understand these concepts but also feel comfortable implementing them, empowering you to build robust, scalable event-driven applications with Knative.

## **Bookstore Architecture**

![Bookstore Architecture](images/5.png)

The bookstore application consists of the following components:

### User Interface

A frontend Next.js application that interacts with these services. It is a web page where users can select a book to view its details, ratings and reviews.

### Database Service

An in-memory PostgreSQL instance on Kubernetes, storing all user comments.

### Book Reviews Service

A Node.js web server that will perform the event forwarding, database operation, and handling the websocket connection.

### Notification Service

An Apache Camel K pipe that connects our event-driven architecture with a third-party webhook: Slack. It receives the CloudEvent and sends it as a message to a Slack Workspace.

### ML Models Service

There are 2 Machine learning workflows that can conduct sentiment analysis on user's review comment and hateful word sanity check. You will be using a [Knative Sequence](https://knative.dev/docs/eventing/flows/sequence/){:target="_blank"} to make sure they are executed in order.

### Book Store Broker

It acts as the central brain of our event-driven architecture. It connects all the microservices together, receives the event, and makes sure all the events are safely delivered to the correct destination.

### Bad Word Broker

It acts as the bridge between the book store Broker and the Slack Sink, so we can send notification to your Slack when a comment containing "bad word" is submitted.

## **Tutorial Page Structure**


We will be building the sample app in this order:

0. [**Environment Setup**](../page-0.5/environment-setup.md){:target="_blank"}: Set up the environment for the tutorial. This includes installing the cluster, the frontend and the backend.

1. [**Send comments to the Broker**](../page-1/send-review-comment-to-broker.md){:target="_blank"}: Pass reviews from the frontend to event-display via the Broker. This involves learning about Broker, SinkBinding and CloudEvents event types.
   
2. [**Deploy Sentiment Analysis Service**](../page-2/sentiment-analysis-service-for-bookstore-reviews.md){:target="_blank"}: Gain knowledge on deploying a sentiment analysis service using Knative Function.

3. [**Deploy Bad Word Filter Service**](../page-3/create-bad-word-filter-service.md){:target="_blank"}: Implement a bad word filter service using Knative Function yourself.

4. [**Use a Sequence to Run the ML Workflows in order**](../page-4/create-sequence-to-streamline-ML-workflows.md){:target="_blank"}: Learn how to utilize a Knative Sequence to ensure your ML workflows executes in order.

5. [**Database Deployment**](../page-5//deploy-database-service.md){:target="_blank"}: Understand the deployment of an in-memory PostgreSQL instance using a plain Kubernetes deployment.

6. [**Advanced event filtering**](../page-6/advanced-event-filtering.md){:target="_blank"}: Integrate all components by receiving "analyzed reviews" via Broker (using a Trigger) and storing them into the database. This includes learning about Triggers and Filters.

7. [**Connect with External Services/API**](../page-7/slack-sink-learning-knative-eventing-and-apache-camel-K-integration.md){:target="_blank"}: Learn how to connect your application with external services and APIs using Knative Eventing and Apache Camel K integrations.

8. [**Extra Challenges**](../extra-challenge/README.md){:target="_blank"}: Additional challenges to test your understanding of the concepts learned in the tutorial.

## **How to properly learn?**

### Preview the Final Bookstore: 1-Minute Demo Video

To help you visualize what you'll be creating, we've prepared a brief demo video. This two-minute preview showcases the final bookstore application, providing a clearer understanding of what you can expect to build.

<iframe width="1924" height="500" src="https://www.youtube.com/embed/5D8pTcQSacw" title="Knative E2E Bookstore Tutorial  - 1-min Demo" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

???+ bug "Video not working above?"
    If the video is not working, you can watch it [here](https://www.youtube.com/watch?v=5D8pTcQSacw&ab_channel=Knative){:target="_blank"}.

### Step-by-Step Guidance for Beginners

![Beginner Guide](images/9.png)

This tutorial is meticulously structured to be beginner-friendly, featuring detailed, step-by-step instructions for building the sample app. Simply follow the sequence we've laid out: each section builds upon the previous, guiding you through the construction of the application. Should you encounter any hurdles, the Knative community is a fantastic resource for support. Don't hesitate to ask questions and seek advice. Check the [Help](#help) section below!

### Accelerated Learning Path for Advanced Users

![Advanced Users Guide](images/10.png)

If you find the tutorial too basic, or if it covers familiar territory, feel free to adjust your learning approach. Each section of the tutorial is accompanied by concise graphics that summarize key concepts. Advanced learners can choose to focus on these graphics to grasp the essentials faster, streamlining the learning experience without sacrificing depth or understanding.

## **Help**

![Help Image](images/11.png)

Join the supportive Knative community via the Cloud Native Computing Foundation (CNCF) Slack, particularly the [#knative](https://cloud-native.slack.com/archives/C04LGHDR9K7){:target="_blank"} channel. Before posting your questions, please search to see if they've already been answered. Your feedback on this tutorial is invaluable, so don't hesitate to reach out with suggestions or questions.

## **Next Step**


![Environment Setup](images/13.png)

Let's set up the environment first.

[Go to Environment Setup :fontawesome-solid-paper-plane:](../page-0.5/environment-setup.md){ .md-button .md-button--primary }
