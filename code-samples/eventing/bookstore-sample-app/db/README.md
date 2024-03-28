# Database Service for Bookstore
To successfully launch the Bookstore sample application, it's essential to set up a dedicated database populated with specific sample data. This guide provides both the schema for the database and the initial data you'll need to get started.

In this tutorial, we'll embark on creating a PostgreSQL database using Kubernetes (K8s) StatefulSets and populating it with the sample data provided.

You might wonder, "Why not leverage Knative Serving to dynamically scale the database service in response to traffic demands?" We'll delve into the optimal scenarios for employing Knative Serving and when it's advantageous for our database service.

## What Knative features will we learn about?
- Appropriate Use Cases for Knative Service

## What does the final deliverable look like?
Our goal is to deploy a PostgreSQL pod within Kubernetes, loaded with the sample data outlined in the accompanying SQL file. This pod will serve as the foundational database service for our bookstore application.

## Overview

### The Database Schema
The BookReviews table contains all reviews made on the bookstore website. 

See the columns of the BookReviews table below:
* `ID (serial)` - Primary Key
* `post_time (datetime)` - Posting time of the comment
* `content (text)` - The contents of the comment
* `sentiment (text)` - The sentiment results (currently, the values it could take on are 'positive' or 'neutral' or 'negative')


### The Sample Data
The sample rows inserted for the BookReviews table are shown below:
| id | post_time           | content                      | sentiment |
|----|---------------------|------------------------------|-----------|
| 1  | 2020-01-01 00:00:00 | This book is great!          | positive  |
| 2  | 2020-01-02 00:02:00 | This book is terrible!       | negative  |
| 3  | 2020-01-03 00:01:30 | This book is okay.           | neutral   |
| 4  | 2020-01-04 00:00:00 | Meh                          | neutral   |




## Implementation

### Step 1: Acquire Necessary Files from the Repository
The essential files for setting up your database are located within the `db` directory of our repository. Please download these files to proceed.

### Step 2: Deploying the PostgreSQL Database
To deploy the PostgreSQL database and populate it with the provided sample data, you'll apply a series of Kubernetes deployment files. Ensure you're positioned in the `code-sample` directory and not within the `db` subdirectory for this operation.

Within this directory, you will find 6 YAML files, each serving a distinct purpose in the setup process:
- `100-create-configmap.yaml`: Generates a ConfigMap including the SQL file for database initialization.
- `100-create-secret.yaml`: Produces a Secret holding the PostgreSQL database password.
- `100-create-volume.yaml`: Creates both a PersistentVolume and a PersistentVolumeClaim for database storage.
- `200-create-postgre.yaml`: Establishes the StatefulSet for the PostgreSQL database.
- `300-expose-service.yaml`: Launches a Service to expose the PostgreSQL database externally.
- `400-create-job.yaml`: Executes a Job that populates the database with the sample data.

Execute the command below to apply all configuration files located in the `db` directory:
```bash
kubectl apply -f db
```
The filenames prefixed with numbers dictate the application order, ensuring Kubernetes orchestrates the resource setup accordingly.

### Step 3: Confirming the Deployment
Following the application of the deployment files, initialization of the database may require some time. Monitor the deployment's progress by executing:
```bash
kubectl get pods -n=default
```
A successful deployment is indicated by the `Running` state of the `postgresql-0` pod, as shown below:
```bash
NAMESPACE     NAME                     READY   STATUS      RESTARTS   AGE
default       postgresql-0             1/1     Running     0          1m
```
Upon observing the pod in a `Running` state, access the pod using the command:
```bash
kubectl exec -it postgresql-0 -n=default -- /bin/bash
```
Inside the pod, connect to the database with:
```bash
psql -U myuser -d mydatabase
```
A successful connection will present you with:
```bash
mydatabase=#
```
To verify the initialization of the `BookReviews` table, execute:
```
mydatabase=# \dt
```
If the output lists the `BookReviews` table as follows, your database has been correctly initialized:
```bash
 List of relations
 Schema |     Name     | Type  | Owner  
--------+--------------+-------+--------
 public | book_reviews | table | myuser
(1 row)
```

## Conclusion

By following this guide, you have successfully deployed a PostgreSQL server on a Kubernetes cluster, set up persistent storage, and initialized your database using a Kubernetes job. Congratulations! Your bookstore now has the database service.