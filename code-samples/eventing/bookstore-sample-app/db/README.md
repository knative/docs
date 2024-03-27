# Database Service for Bookstore
In order to run the Bookstore sample application, you need to create a database and populate it with sample data. This document provides the schema and sample data for the database.

In this tutorial, we will create a PostgreSQL database and populate it with sample data. We will then create **a k8s deployment** that connects to the PostgreSQL database.

We will be discussing when we should use Knative Service and what benefit it can bring to us.
## What Knative features will we learn about?
- Knative Service

## What does the final deliverable look like?
A k8s deployment file that creates a Knative Service that connects to a PostgreSQL database contains the sample data we specified in the SQL file.

## Overview

### The Database Schema
The BookReviews table contains all reviews made on the bookstore website. 

See the columns of the BookReviews table below:
* ID (serial) - Primary Key
* post_time (datetime) - Posting time of the comment
* content (text) - The contents of the comment
* sentiment (text) - The sentiment results (currently, the values it could take on are 'positive' or 'neutral' or 'negative')


### The Sample Data
The sample rows inserted for the BookReviews table are shown below:
| id | post_time           | content                      | sentiment |
|----|---------------------|------------------------------|-----------|
| 1  | 2020-01-01 00:00:00 | This book is great!          | positive  |
| 2  | 2020-01-02 00:02:00 | This book is terrible!       | negative  |
| 3  | 2020-01-03 00:01:30 | This book is okay.           | neutral   |
| 4  | 2020-01-04 00:00:00 | Meh                          | neutral   |





## Implementation
### Step 1: Create a ConfigMap for SQL Configuration

Use the following command to create a ConfigMap named `sql-configmap` from your `sample.sql` file. This ConfigMap will be used to store your SQL script.

```bash
kubectl create configmap sql-configmap --from-file=sample.sql
```

### Step 2: Set Up Persistent Storage

Persistent Volume Claims (PVCs) provide a way to request storage for your database that persists beyond the lifecycle of a pod. Apply your PVC configuration to ensure your PostgreSQL database has the necessary storage.

```bash
kubectl apply -f PVC.yaml
```

### Step 3: Deploy the PostgreSQL Server

Deploy your PostgreSQL server as a pod within your Kubernetes cluster. This deployment will utilize the PVC created in the previous step for storage.

```bash
kubectl apply -f deployment.yaml
```

### Step 4: Expose PostgreSQL Service

Expose your PostgreSQL server within the Kubernetes cluster to allow connections to the database.

```bash
kubectl apply -f service.yaml
```

### Step 5: Initialize the Database

Execute the SQL commands from your `sample.sql` file by running a Kubernetes job. This job ensures your database schema and initial data are set up according to your specifications.

```bash
kubectl apply -f job.yaml
```

### Step 6: Interact with Your Database

After setting up your database, you may want to interact with it to run queries or manage data.

1. Retrieve the name of your PostgreSQL deployment pod:

```bash
kubectl get pods -l app=postgresql
```

2. Enter the pod’s shell:

```bash
kubectl exec -it <deployment pod name> -- /bin/bash
```

3. Connect to your PostgreSQL database:

```bash
psql -h postgresql -U myuser -d mydatabase
```
Use `mypassword` when prompted for the password.

## Conclusion

By following this guide, you have successfully deployed a PostgreSQL server on a Kubernetes cluster, set up persistent storage, and initialized your database using a Kubernetes job. Congratulations! Your bookstore now has the database service.