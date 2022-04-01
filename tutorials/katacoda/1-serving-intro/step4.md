## Basics of Traffic Splitting

The last super power 🚀 of Knative Serving we'll go over in this tutorial is **traffic splitting**.

> **What are some common traffic splitting use-cases?**
> Splitting traffic is useful for a number of very common modern infrastructure needs, 
> such as **[blue/green deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html) and** 
> **[canary deployments](https://martinfowler.com/bliki/CanaryRelease.html)**. Bringing these industry standards 
> to bear on Kubernetes is as simple **as a single CLI command on Knative** or YAML tweak, 
> let's see how! 


### Creating a new Revision
A new Revision gets created each and every time you make changes to the configuration of your Knative Service. 
When splitting traffic, Knative splits traffic between different Revisions of your Knative Service.

> **What exactly is a Revision?**
> You can think of a [Revision](https://knative.dev/docs/serving/#serving-resources) snapshot-in-time of application 
> code and configuration.

#### Create a new Revision
Instead of `TARGET=World` update the environment variable `TARGET` on your Knative Service `hello` to greet "Knative" 
instead.

```sh
kn service update hello --env TARGET=Knative
```{{execute T1}}

As before, `kn` prints out some helpful information to the CLI.

**Expected output:**
```sh
Service 'hello' created to latest revision 'hello-00002' is available at URL:
http://hello.default.example.com
```

Note that since we are updating an existing Knative Service `hello`, the URL doesn't change, but our new Revision 
should have the new name `hello-00002`.

#### Access the new Revision
To see the change, access the Knative Service again using curl in your terminal:
`curl -H "Host: hello.default.example.com" $externalIP`{{execute T1}}
**Expected output:**
```sh
Hello Knative!
```

### Splitting Traffic
You may at this point be wondering, "where did 'Hello World!' go?" Remember, Revisions are an immutable 
snapshot-in-time of application code and configuration, so your old `hello-00001` Revision is still available to you.

#### List your Revisions
We can easily see a list of our existing Revisions with the `kn` or `kubectl` CLI.

```sh
kn revisions list
```{{execute T1}}

**Expected output:**
```sh
NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-00002     hello     100%             2            30s   3 OK / 4     True
hello-00001     hello                      1            5m    3 OK / 4     True
```

When running the `kn` command, the column most relevant for our purposes is `TRAFFIC`. We can see that 100% of traffic is 
going to our latest Revision, `hello-00002`, which is on the row with the highest `GENERATION`. 0% of traffic is going 
to the Revision we configured earlier, `hello-00001`.

When you create a new Revision of a Knative Service, Knative defaults to directing 100% of traffic to this latest 
Revision. **We can change this default behavior by specifying how much traffic we want each of our Revisions to receive**.

#### Split traffic between Revisions
Lets split traffic between our two Revisions:

```sh
kn service update hello --traffic hello-00001=50 --traffic @latest=50
```{{execute T1}}

> **Info**
> `@latest` will always point to our "latest" Revision which, at the moment, is `hello-00002`.


#### Verify the traffic split
To verify that the traffic split has configured correctly, list the revisions again by running the command:
```sh
kn revisions list
```{{execute T1}}

**Expected output:**
```sh
NAME            SERVICE   TRAFFIC   TAGS   GENERATION   AGE   CONDITIONS   READY   REASON
hello-00002     hello     50%              2            10m   3 OK / 4     True
hello-00001     hello     50%              1            36m   3 OK / 4     True
```

Access your Knative Service multiple times in your browser to see the different output being served by each Revision.

Similarly, you can access the Service URL from the terminal multiple times to see the traffic being split between the Revisions.


`curl -H "Host: hello.default.example.com" $externalIP`{{execute T1}}
**Expected output:**
```sh
Hello Knative!
Hello World!
Hello Knative!
Hello World!
```
