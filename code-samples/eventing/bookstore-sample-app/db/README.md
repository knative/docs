# Bookstore Database

1. Database Schema
2. Sample Data
3. Deployment on K8s Cluster

## 1. Database Schema

### BookReviews Table
The BookReviews table contains all reviews made on the bookstore website. 

See the columns of the BookReviews table below:
* ID (serial) - Primary Key
* post_time (datetime) - Posting time of the comment
* content (text) - The contents of the comment
* sentiment (text) - The sentiment results (currently, the values it could take on are 'positive' or 'neutral' or 'negative')

## 2. Sample Data

### BookReviews Table
The sample rows inserted for the BookReviews table are shown below:
| id | post_time           | content                      | sentiment |
|----|---------------------|------------------------------|-----------|
| 1  | 2020-01-01 00:00:00 | This book is great!          | positive  |
| 2  | 2020-01-02 00:02:00 | This book is terrible!       | negative  |
| 3  | 2020-01-03 00:01:30 | This book is okay.           | neutral   |
| 4  | 2020-01-04 00:00:00 | Meh                          | neutral   |

## 3. Deployment on K8s Cluster
1. Set up a Kubernetes Cluster
i. [minikube start](https://minikube.sigs.k8s.io/docs/start/)
ii. [kind quickstart](https://kind.sigs.k8s.io/docs/user/quick-start/)

2. Set up the configmap to link the sample.sql file
`kubectl create configmap sql-configmap --from-file=sample.sql`

3. Stand up the Persistent Volume Claim for Postgres server
`kubectl apply -f PVC.yaml`

4. Create the deployment pod for the Postgres server
`kubectl apply -f deployment.yaml`

5. Expose the port for the Postgres server
`kubectl apply -f service.yaml`

6. Run the job for executing the queries from sample.sql
`kubectl apply -f job.yaml`

7. To interact with the database
i. Get the deployment pod name: `kubectl get pods -l app=postgresql`
ii. `kubectl exec -it (deployment pod name) -- /bin/bash`
iii. `psql -h postgresql -U myuser -d mydatabase`
iv. Use `mypassword` when prompted for the password