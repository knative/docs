<p>Packages:</p>
<ul>
<li>
<a href="#sources.eventing.knative.dev">sources.eventing.knative.dev</a>
</li>
</ul>
<h2 id="sources.eventing.knative.dev">sources.eventing.knative.dev</h2>
<p>
<p>Package v1alpha1 contains API Schema definitions for the sources v1alpha1 API group</p>
</p>
Resource Types:
<ul><li>
<a href="#AwsSqsSource">AwsSqsSource</a>
</li><li>
<a href="#ContainerSource">ContainerSource</a>
</li><li>
<a href="#CronJobSource">CronJobSource</a>
</li><li>
<a href="#GitHubSource">GitHubSource</a>
</li><li>
<a href="#KubernetesEventSource">KubernetesEventSource</a>
</li></ul>
<h3 id="AwsSqsSource">AwsSqsSource
</h3>
<p>
<p>AwsSqsSource is the Schema for the AWS SQS API</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>apiVersion</code></br>
string</td>
<td>
<code>
sources.eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>AwsSqsSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#AwsSqsSourceSpec">
AwsSqsSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>queueUrl</code></br>
<em>
string
</em>
</td>
<td>
<p>QueueURL of the SQS queue that we will poll from.</p>
</td>
</tr>
<tr>
<td>
<code>awsCredsSecret</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<p>AwsCredsSecret is the credential to use to poll the AWS SQS</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to
use as the sink.  This is where events will be received.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<p>ServiceAccoutName is the name of the ServiceAccount that will be used to
run the Receive Adapter Deployment.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#AwsSqsSourceStatus">
AwsSqsSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="ContainerSource">ContainerSource
</h3>
<p>
<p>ContainerSource is the Schema for the containersources API</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>apiVersion</code></br>
string</td>
<td>
<code>
sources.eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>ContainerSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#ContainerSourceSpec">
ContainerSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>image</code></br>
<em>
string
</em>
</td>
<td>
<p>Image is the image to run inside of the container.</p>
</td>
</tr>
<tr>
<td>
<code>args</code></br>
<em>
[]string
</em>
</td>
<td>
<p>Args are passed to the ContainerSpec as they are.</p>
</td>
</tr>
<tr>
<td>
<code>env</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvar-v1-core">
[]Kubernetes core/v1.EnvVar
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Env is the list of environment variables to set in the container.
Cannot be updated.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName is the name of the ServiceAccount to use to run this
source.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#ContainerSourceStatus">
ContainerSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="CronJobSource">CronJobSource
</h3>
<p>
<p>CronJobSource is the Schema for the cronjobsources API.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>apiVersion</code></br>
string</td>
<td>
<code>
sources.eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>CronJobSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#CronJobSourceSpec">
CronJobSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<p>Schedule is the cronjob schedule.</p>
</td>
</tr>
<tr>
<td>
<code>data</code></br>
<em>
string
</em>
</td>
<td>
<p>Data is the data posted to the target function.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<p>ServiceAccoutName is the name of the ServiceAccount that will be used to run the Receive
Adapter Deployment.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#CronJobSourceStatus">
CronJobSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="GitHubSource">GitHubSource
</h3>
<p>
<p>GitHubSource is the Schema for the githubsources API</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>apiVersion</code></br>
string</td>
<td>
<code>
sources.eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>GitHubSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#GitHubSourceSpec">
GitHubSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName holds the name of the Kubernetes service account
as which the underlying K8s resources should be run. If unspecified
this will default to the &ldquo;default&rdquo; service account for the namespace
in which the GitHubSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>ownerAndRepository</code></br>
<em>
string
</em>
</td>
<td>
<p>OwnerAndRepository is the GitHub owner/org and repository to
receive events from. The repository may be left off to receive
events from an entire organization.
Examples:
myuser/project
myorganization</p>
</td>
</tr>
<tr>
<td>
<code>eventTypes</code></br>
<em>
[]string
</em>
</td>
<td>
<p>EventType is the type of event to receive from GitHub. These
correspond to the &ldquo;Webhook event name&rdquo; values listed at
<a href="https://developer.github.com/v3/activity/events/types/">https://developer.github.com/v3/activity/events/types/</a> - ie
&ldquo;pull_request&rdquo;</p>
</td>
</tr>
<tr>
<td>
<code>accessToken</code></br>
<em>
<a href="#SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>AccessToken is the Kubernetes secret containing the GitHub
access token</p>
</td>
</tr>
<tr>
<td>
<code>secretToken</code></br>
<em>
<a href="#SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>SecretToken is the Kubernetes secret containing the GitHub
secret token</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain
name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>githubAPIURL</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>API URL if using github enterprise (default <a href="https://api.github.com">https://api.github.com</a>)</p>
</td>
</tr>
<tr>
<td>
<code>secure</code></br>
<em>
bool
</em>
</td>
<td>
<em>(Optional)</em>
<p>Secure can be set to true to configure the webhook to use https.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#GitHubSourceStatus">
GitHubSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="KubernetesEventSource">KubernetesEventSource
</h3>
<p>
<p>KubernetesEventSource is the Schema for the kuberneteseventsources API</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>apiVersion</code></br>
string</td>
<td>
<code>
sources.eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>KubernetesEventSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#KubernetesEventSourceSpec">
KubernetesEventSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>namespace</code></br>
<em>
string
</em>
</td>
<td>
<p>Namespace that we watch kubernetes events in.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName is the name of the ServiceAccount to use to run this
source.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use
as the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#KubernetesEventSourceStatus">
KubernetesEventSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="AwsSqsSourceSpec">AwsSqsSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#AwsSqsSource">AwsSqsSource</a>)
</p>
<p>
<p>AwsSqsSourceSpec defines the desired state of the source.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>queueUrl</code></br>
<em>
string
</em>
</td>
<td>
<p>QueueURL of the SQS queue that we will poll from.</p>
</td>
</tr>
<tr>
<td>
<code>awsCredsSecret</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<p>AwsCredsSecret is the credential to use to poll the AWS SQS</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to
use as the sink.  This is where events will be received.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<p>ServiceAccoutName is the name of the ServiceAccount that will be used to
run the Receive Adapter Deployment.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="AwsSqsSourceStatus">AwsSqsSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#AwsSqsSource">AwsSqsSource</a>)
</p>
<p>
<p>AwsSqsSourceStatus defines the observed state of the source.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Status">
github.com/knative/pkg/apis/duck/v1alpha1.Status
</a>
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1alpha1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured for the source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ContainerSourceSpec">ContainerSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#ContainerSource">ContainerSource</a>)
</p>
<p>
<p>ContainerSourceSpec defines the desired state of ContainerSource</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>image</code></br>
<em>
string
</em>
</td>
<td>
<p>Image is the image to run inside of the container.</p>
</td>
</tr>
<tr>
<td>
<code>args</code></br>
<em>
[]string
</em>
</td>
<td>
<p>Args are passed to the ContainerSpec as they are.</p>
</td>
</tr>
<tr>
<td>
<code>env</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#envvar-v1-core">
[]Kubernetes core/v1.EnvVar
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Env is the list of environment variables to set in the container.
Cannot be updated.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName is the name of the ServiceAccount to use to run this
source.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ContainerSourceStatus">ContainerSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#ContainerSource">ContainerSource</a>)
</p>
<p>
<p>ContainerSourceStatus defines the observed state of ContainerSource</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Status">
github.com/knative/pkg/apis/duck/v1alpha1.Status
</a>
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1alpha1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured for the ContainerSource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="CronJobSourceSpec">CronJobSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CronJobSource">CronJobSource</a>)
</p>
<p>
<p>CronJobSourceSpec defines the desired state of the CronJobSource.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<p>Schedule is the cronjob schedule.</p>
</td>
</tr>
<tr>
<td>
<code>data</code></br>
<em>
string
</em>
</td>
<td>
<p>Data is the data posted to the target function.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<p>ServiceAccoutName is the name of the ServiceAccount that will be used to run the Receive
Adapter Deployment.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="CronJobSourceStatus">CronJobSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#CronJobSource">CronJobSource</a>)
</p>
<p>
<p>CronJobSourceStatus defines the observed state of CronJobSource.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Status">
github.com/knative/pkg/apis/duck/v1alpha1.Status
</a>
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1alpha1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured for the CronJobSource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="GitHubSourceSpec">GitHubSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#GitHubSource">GitHubSource</a>)
</p>
<p>
<p>GitHubSourceSpec defines the desired state of GitHubSource</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName holds the name of the Kubernetes service account
as which the underlying K8s resources should be run. If unspecified
this will default to the &ldquo;default&rdquo; service account for the namespace
in which the GitHubSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>ownerAndRepository</code></br>
<em>
string
</em>
</td>
<td>
<p>OwnerAndRepository is the GitHub owner/org and repository to
receive events from. The repository may be left off to receive
events from an entire organization.
Examples:
myuser/project
myorganization</p>
</td>
</tr>
<tr>
<td>
<code>eventTypes</code></br>
<em>
[]string
</em>
</td>
<td>
<p>EventType is the type of event to receive from GitHub. These
correspond to the &ldquo;Webhook event name&rdquo; values listed at
<a href="https://developer.github.com/v3/activity/events/types/">https://developer.github.com/v3/activity/events/types/</a> - ie
&ldquo;pull_request&rdquo;</p>
</td>
</tr>
<tr>
<td>
<code>accessToken</code></br>
<em>
<a href="#SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>AccessToken is the Kubernetes secret containing the GitHub
access token</p>
</td>
</tr>
<tr>
<td>
<code>secretToken</code></br>
<em>
<a href="#SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>SecretToken is the Kubernetes secret containing the GitHub
secret token</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain
name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>githubAPIURL</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>API URL if using github enterprise (default <a href="https://api.github.com">https://api.github.com</a>)</p>
</td>
</tr>
<tr>
<td>
<code>secure</code></br>
<em>
bool
</em>
</td>
<td>
<em>(Optional)</em>
<p>Secure can be set to true to configure the webhook to use https.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="GitHubSourceStatus">GitHubSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#GitHubSource">GitHubSource</a>)
</p>
<p>
<p>GitHubSourceStatus defines the observed state of GitHubSource</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Status">
github.com/knative/pkg/apis/duck/v1alpha1.Status
</a>
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1alpha1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>webhookIDKey</code></br>
<em>
string
</em>
</td>
<td>
<p>WebhookIDKey is the ID of the webhook registered with GitHub</p>
</td>
</tr>
<tr>
<td>
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured
for the GitHubSource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="KubernetesEventSourceSpec">KubernetesEventSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#KubernetesEventSource">KubernetesEventSource</a>)
</p>
<p>
<p>KubernetesEventSourceSpec defines the desired state of the source.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>namespace</code></br>
<em>
string
</em>
</td>
<td>
<p>Namespace that we watch kubernetes events in.</p>
</td>
</tr>
<tr>
<td>
<code>serviceAccountName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceAccountName is the name of the ServiceAccount to use to run this
source.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use
as the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="KubernetesEventSourceStatus">KubernetesEventSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#KubernetesEventSource">KubernetesEventSource</a>)
</p>
<p>
<p>KubernetesEventSourceStatus defines the observed state of the source.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Status">
github.com/knative/pkg/apis/duck/v1alpha1.Status
</a>
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1alpha1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured for the source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#GitHubSourceSpec">GitHubSourceSpec</a>)
</p>
<p>
<p>SecretValueFromSource represents the source of a secret value</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>secretKeyRef</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<p>The Secret key to select from.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>32ce3778</code>.
</em></p>
