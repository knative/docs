<p>Packages:</p>
<ul>
<li>
<a href="#messaging.knative.dev%2fv1alpha1">messaging.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#sources.knative.dev%2fv1alpha1">sources.knative.dev/v1alpha1</a>
</li>
</ul>
<h2 id="messaging.knative.dev/v1alpha1">messaging.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannel">KafkaChannel</a>
</li><li>
<a href="#messaging.knative.dev/v1alpha1.NatssChannel">NatssChannel</a>
</li></ul>
<h3 id="messaging.knative.dev/v1alpha1.KafkaChannel">KafkaChannel
</h3>
<p>
<p>KafkaChannel is a resource representing a Kafka Channel.</p>
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
messaging.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>KafkaChannel</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannelSpec">
KafkaChannelSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Channel.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>numPartitions</code></br>
<em>
int32
</em>
</td>
<td>
<p>NumPartitions is the number of partitions of a Kafka topic. By default, it is set to 1.</p>
</td>
</tr>
<tr>
<td>
<code>replicationFactor</code></br>
<em>
int16
</em>
</td>
<td>
<p>ReplicationFactor is the replication factor of a Kafka topic. By default, it is set to 1.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.Subscribable
</em>
</td>
<td>
<p>KafkaChannel conforms to Duck type Subscribable.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannelStatus">
KafkaChannelStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the KafkaChannel. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.NatssChannel">NatssChannel
</h3>
<p>
<p>NatssChannel is a resource representing a NATSS Channel.</p>
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
messaging.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>NatssChannel</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
Kubernetes meta/v1.ObjectMeta
</a>
</em>
</td>
<td>
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.NatssChannelSpec">
NatssChannelSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Channel.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>subscribable</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.Subscribable
</em>
</td>
<td>
<p>NatssChannel conforms to Duck type Subscribable.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.NatssChannelStatus">
NatssChannelStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the NatssChannel. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.KafkaChannelSpec">KafkaChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannel">KafkaChannel</a>)
</p>
<p>
<p>KafkaChannelSpec defines the specification for a KafkaChannel.</p>
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
<code>numPartitions</code></br>
<em>
int32
</em>
</td>
<td>
<p>NumPartitions is the number of partitions of a Kafka topic. By default, it is set to 1.</p>
</td>
</tr>
<tr>
<td>
<code>replicationFactor</code></br>
<em>
int16
</em>
</td>
<td>
<p>ReplicationFactor is the replication factor of a Kafka topic. By default, it is set to 1.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.Subscribable
</em>
</td>
<td>
<p>KafkaChannel conforms to Duck type Subscribable.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.KafkaChannelStatus">KafkaChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannel">KafkaChannel</a>)
</p>
<p>
<p>KafkaChannelStatus represents the current state of a KafkaChannel.</p>
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
knative.dev/pkg/apis/duck/v1beta1.Status
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1beta1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>AddressStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.AddressStatus
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>KafkaChannel is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.SubscribableTypeStatus
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeStatus</code> are embedded into this type.)
</p>
<p>Subscribers is populated with the statuses of each of the Channelable&rsquo;s subscribers.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.NatssChannelSpec">NatssChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.NatssChannel">NatssChannel</a>)
</p>
<p>
<p>NatssChannelSpec defines the specification for a NatssChannel.</p>
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
<code>subscribable</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.Subscribable
</em>
</td>
<td>
<p>NatssChannel conforms to Duck type Subscribable.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.NatssChannelStatus">NatssChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.NatssChannel">NatssChannel</a>)
</p>
<p>
<p>NatssChannelStatus represents the current state of a NatssChannel.</p>
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
knative.dev/pkg/apis/duck/v1beta1.Status
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1beta1 Status, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>AddressStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.AddressStatus
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>NatssChannel is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1alpha1.SubscribableTypeStatus
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeStatus</code> are embedded into this type.)
</p>
<p>Subscribers is populated with the statuses of each of the Channelable&rsquo;s subscribers.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="sources.knative.dev/v1alpha1">sources.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 contains API Schema definitions for the sources v1alpha1 API group</p>
</p>
Resource Types:
<ul><li>
<a href="#sources.knative.dev/v1alpha1.AwsSqsSource">AwsSqsSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.CamelSource">CamelSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.CouchDbSource">CouchDbSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.GitHubSource">GitHubSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.GitLabSource">GitLabSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.PrometheusSource">PrometheusSource</a>
</li></ul>
<h3 id="sources.knative.dev/v1alpha1.AwsSqsSource">AwsSqsSource
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
sources.knative.dev/v1alpha1
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.AwsSqsSourceSpec">
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>AwsCredsSecret is the credential to use to poll the AWS SQS</p>
</td>
</tr>
<tr>
<td>
<code>annotations</code></br>
<em>
map[string]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Annotations to add to the pod, mostly used for Kube2IAM role</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
<a href="#sources.knative.dev/v1alpha1.AwsSqsSourceStatus">
AwsSqsSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CamelSource">CamelSource
</h3>
<p>
<p>CamelSource is the Schema for the camelsources API</p>
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
sources.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>CamelSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.CamelSourceSpec">
CamelSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>source</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.CamelSourceOriginSpec">
CamelSourceOriginSpec
</a>
</em>
</td>
<td>
<p>Source is the reference to the integration flow to run.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1beta1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>ceOverrides</code></br>
<em>
knative.dev/pkg/apis/duck/v1.CloudEventOverrides
</em>
</td>
<td>
<em>(Optional)</em>
<p>CloudEventOverrides defines overrides to control the output format and
modifications of the event sent to the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.CamelSourceStatus">
CamelSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CouchDbSource">CouchDbSource
</h3>
<p>
<p>CouchDbSource is the Schema for the githubsources API</p>
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
sources.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>CouchDbSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.CouchDbSourceSpec">
CouchDbSourceSpec
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
in which the CouchDbSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>credentials</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>CouchDbCredentials is the credential to use to access CouchDb.
Must be a secret. Only Name and Namespace are used.</p>
</td>
</tr>
<tr>
<td>
<code>feed</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.FeedType">
FeedType
</a>
</em>
</td>
<td>
<p>Feed changes how CouchDB sends the response.
More information: <a href="https://docs.couchdb.org/en/stable/api/database/changes.html#changes-feeds">https://docs.couchdb.org/en/stable/api/database/changes.html#changes-feeds</a></p>
</td>
</tr>
<tr>
<td>
<code>database</code></br>
<em>
string
</em>
</td>
<td>
<p>Database is the database to watch for changes</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
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
<a href="#sources.knative.dev/v1alpha1.CouchDbSourceStatus">
CouchDbSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.GitHubSource">GitHubSource
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
sources.knative.dev/v1alpha1
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.GitHubSourceSpec">
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
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
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
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
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
knative.dev/pkg/apis/duck/v1.Destination
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
<p>Secure can be set to true to configure the webhook to use https,
or false to use http.  Omitting it relies on the scheme of the
Knative Service created (e.g. if auto-TLS is enabled it should
do the right thing).</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.GitHubSourceStatus">
GitHubSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.GitLabSource">GitLabSource
</h3>
<p>
<p>GitLabSource is the Schema for the gitlabsources API</p>
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
sources.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>GitLabSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.GitLabSourceSpec">
GitLabSourceSpec
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
in which the GitLabSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>projectUrl</code></br>
<em>
string
</em>
</td>
<td>
<p>ProjectUrl is the url of the GitLab project we want to receive events from.
Examples:
<a href="https://github.com/knative/eventing-contrib/tree/master/gitlab/">https://github.com/knative/eventing-contrib/tree/master/gitlab/</a></p>
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
<p>EventType is the type of event to receive from Gitlab. These
correspond to supported events to the add project hook
<a href="https://docs.gitlab.com/ee/api/projects.html#add-project-hook">https://docs.gitlab.com/ee/api/projects.html#add-project-hook</a></p>
</td>
</tr>
<tr>
<td>
<code>accessToken</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>AccessToken is the Kubernetes secret containing the GitLab
access token</p>
</td>
</tr>
<tr>
<td>
<code>secretToken</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>SecretToken is the Kubernetes secret containing the GitLab
secret token</p>
</td>
</tr>
<tr>
<td>
<code>sslverify</code></br>
<em>
bool
</em>
</td>
<td>
<p>SslVerify if true configure webhook so the ssl verification is done when triggering the hook</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain
name to use as the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.GitLabSourceStatus">
GitLabSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.PrometheusSource">PrometheusSource
</h3>
<p>
<p>PrometheusSource is the Schema for the prometheussources API</p>
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
sources.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>PrometheusSource</code></td>
</tr>
<tr>
<td>
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.PrometheusSourceSpec">
PrometheusSourceSpec
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
in which the PrometheusSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>serverURL</code></br>
<em>
string
</em>
</td>
<td>
<p>ServerURL is the URL of the Prometheus server</p>
</td>
</tr>
<tr>
<td>
<code>promQL</code></br>
<em>
string
</em>
</td>
<td>
<p>PromQL is the Prometheus query for this source</p>
</td>
</tr>
<tr>
<td>
<code>authTokenFile</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>The name of the file containing the authenication token</p>
</td>
</tr>
<tr>
<td>
<code>caCertConfigMap</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>The name of the config map containing the CA certificate of the
Prometheus service&rsquo;s signer.</p>
</td>
</tr>
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<p>A crontab-formatted schedule for running the PromQL query</p>
</td>
</tr>
<tr>
<td>
<code>step</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Query resolution step width in duration format or float number of seconds.
Prometheus duration strings are of the form [0-9]+[smhdwy].</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a host
name to use as the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.PrometheusSourceStatus">
PrometheusSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.AwsSqsSourceSpec">AwsSqsSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.AwsSqsSource">AwsSqsSource</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>AwsCredsSecret is the credential to use to poll the AWS SQS</p>
</td>
</tr>
<tr>
<td>
<code>annotations</code></br>
<em>
map[string]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Annotations to add to the pod, mostly used for Kube2IAM role</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
<h3 id="sources.knative.dev/v1alpha1.AwsSqsSourceStatus">AwsSqsSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.AwsSqsSource">AwsSqsSource</a>)
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CamelSourceOriginSpec">CamelSourceOriginSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CamelSourceSpec">CamelSourceSpec</a>)
</p>
<p>
<p>CamelSourceOriginSpec is the integration flow to run</p>
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
<code>integration</code></br>
<em>
github.com/apache/camel-k/pkg/apis/camel/v1.IntegrationSpec
</em>
</td>
<td>
<p>Integration is a kind of source that contains a Camel K integration</p>
</td>
</tr>
<tr>
<td>
<code>flow</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.Flow">
Flow
</a>
</em>
</td>
<td>
<p>Flow is a kind of source that contains a single Camel YAML flow route</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CamelSourceSpec">CamelSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CamelSource">CamelSource</a>)
</p>
<p>
<p>CamelSourceSpec defines the desired state of CamelSource</p>
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
<code>source</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.CamelSourceOriginSpec">
CamelSourceOriginSpec
</a>
</em>
</td>
<td>
<p>Source is the reference to the integration flow to run.</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1beta1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
<tr>
<td>
<code>ceOverrides</code></br>
<em>
knative.dev/pkg/apis/duck/v1.CloudEventOverrides
</em>
</td>
<td>
<em>(Optional)</em>
<p>CloudEventOverrides defines overrides to control the output format and
modifications of the event sent to the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CamelSourceStatus">CamelSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CamelSource">CamelSource</a>)
</p>
<p>
<p>CamelSourceStatus defines the observed state of CamelSource</p>
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
knative.dev/pkg/apis/duck/v1.Status
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
<p>SinkURI is the current active sink URI that has been configured for the CamelSource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CouchDbSourceSpec">CouchDbSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CouchDbSource">CouchDbSource</a>)
</p>
<p>
<p>CouchDbSourceSpec defines the desired state of CouchDbSource</p>
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
in which the CouchDbSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>credentials</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>CouchDbCredentials is the credential to use to access CouchDb.
Must be a secret. Only Name and Namespace are used.</p>
</td>
</tr>
<tr>
<td>
<code>feed</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.FeedType">
FeedType
</a>
</em>
</td>
<td>
<p>Feed changes how CouchDB sends the response.
More information: <a href="https://docs.couchdb.org/en/stable/api/database/changes.html#changes-feeds">https://docs.couchdb.org/en/stable/api/database/changes.html#changes-feeds</a></p>
</td>
</tr>
<tr>
<td>
<code>database</code></br>
<em>
string
</em>
</td>
<td>
<p>Database is the database to watch for changes</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain name to use as the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.CouchDbSourceStatus">CouchDbSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CouchDbSource">CouchDbSource</a>)
</p>
<p>
<p>CouchDbSourceStatus defines the observed state of CouchDbSource</p>
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.FeedType">FeedType
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CouchDbSourceSpec">CouchDbSourceSpec</a>)
</p>
<p>
<p>FeedType is the type of Feed</p>
</p>
<h3 id="sources.knative.dev/v1alpha1.Flow">Flow
(<code>map[string]interface{}</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.CamelSourceOriginSpec">CamelSourceOriginSpec</a>)
</p>
<p>
<p>Flow is an unstructured object representing a Camel Flow in YAML/JSON DSL</p>
</p>
<h3 id="sources.knative.dev/v1alpha1.GitHubSourceSpec">GitHubSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitHubSource">GitHubSource</a>)
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
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
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
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
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
knative.dev/pkg/apis/duck/v1.Destination
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
<p>Secure can be set to true to configure the webhook to use https,
or false to use http.  Omitting it relies on the scheme of the
Knative Service created (e.g. if auto-TLS is enabled it should
do the right thing).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.GitHubSourceStatus">GitHubSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitHubSource">GitHubSource</a>)
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
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
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.GitLabSourceSpec">GitLabSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitLabSource">GitLabSource</a>)
</p>
<p>
<p>GitLabSourceSpec defines the desired state of GitLabSource</p>
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
in which the GitLabSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>projectUrl</code></br>
<em>
string
</em>
</td>
<td>
<p>ProjectUrl is the url of the GitLab project which we are interested
in receiving events from.
Examples:
<a href="https://github.com/knative/eventing-contrib/tree/{{% branch %}}/gitlab/samples">https://github.com/knative/eventing-contrib/tree/{{% branch %}}/gitlab/samples</a></p>
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
<p>EventType is the type of event to receive from Gitlab. These
correspond to supported events to the add project hook
<a href="https://docs.gitlab.com/ee/api/projects.html#add-project-hook">https://docs.gitlab.com/ee/api/projects.html#add-project-hook</a></p>
</td>
</tr>
<tr>
<td>
<code>accessToken</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>AccessToken is the Kubernetes secret containing the GitLab
access token</p>
</td>
</tr>
<tr>
<td>
<code>secretToken</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<p>SecretToken is the Kubernetes secret containing the GitLab
secret token</p>
</td>
</tr>
<tr>
<td>
<code>sslverify</code></br>
<em>
bool
</em>
</td>
<td>
<p>SslVerify if true configure webhook so the ssl verification is done when triggering the hook</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a domain
name to use as the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.GitLabSourceStatus">GitLabSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitLabSource">GitLabSource</a>)
</p>
<p>
<p>GitLabSourceStatus defines the observed state of GitLabSource</p>
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
</td>
</tr>
<tr>
<td>
<code>Id</code></br>
<em>
string
</em>
</td>
<td>
<p>ID of the project hook registered with GitLab</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaLimitsSpec">KafkaLimitsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaResourceSpec">KafkaResourceSpec</a>)
</p>
<p>
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
<code>cpu</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>memory</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaRequestsSpec">KafkaRequestsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaResourceSpec">KafkaResourceSpec</a>)
</p>
<p>
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
<code>cpu</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>memory</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaResourceSpec">KafkaResourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSpec">KafkaSourceSpec</a>)
</p>
<p>
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
<code>requests</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaRequestsSpec">
KafkaRequestsSpec
</a>
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>limits</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaLimitsSpec">
KafkaLimitsSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaSource">KafkaSource
</h3>
<p>
<p>KafkaSource is the Schema for the kafkasources API.</p>
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
<code>metadata</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSpec">
KafkaSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>bootstrapServers</code></br>
<em>
string
</em>
</td>
<td>
<p>Bootstrap servers are the Kafka servers the consumer will connect to.</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
string
</em>
</td>
<td>
<p>Topic topics to consume messages from</p>
</td>
</tr>
<tr>
<td>
<code>consumerGroup</code></br>
<em>
string
</em>
</td>
<td>
<p>ConsumerGroupID is the consumer group ID.</p>
</td>
</tr>
<tr>
<td>
<code>net</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceNetSpec">
KafkaSourceNetSpec
</a>
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaResourceSpec">
KafkaResourceSpec
</a>
</em>
</td>
<td>
<p>Resource limits and Request specifications of the Receive Adapter Deployment</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceStatus">
KafkaSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaSourceNetSpec">KafkaSourceNetSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSpec">KafkaSourceSpec</a>)
</p>
<p>
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
<code>sasl</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSASLSpec">
KafkaSourceSASLSpec
</a>
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>tls</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceTLSSpec">
KafkaSourceTLSSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaSourceSASLSpec">KafkaSourceSASLSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceNetSpec">KafkaSourceNetSpec</a>)
</p>
<p>
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
<code>enable</code></br>
<em>
bool
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>user</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>User is the Kubernetes secret containing the SASL username.</p>
</td>
</tr>
<tr>
<td>
<code>password</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Password is the Kubernetes secret containing the SASL password.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaSourceSpec">KafkaSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSource">KafkaSource</a>)
</p>
<p>
<p>KafkaSourceSpec defines the desired state of the KafkaSource.</p>
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
<code>bootstrapServers</code></br>
<em>
string
</em>
</td>
<td>
<p>Bootstrap servers are the Kafka servers the consumer will connect to.</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
string
</em>
</td>
<td>
<p>Topic topics to consume messages from</p>
</td>
</tr>
<tr>
<td>
<code>consumerGroup</code></br>
<em>
string
</em>
</td>
<td>
<p>ConsumerGroupID is the consumer group ID.</p>
</td>
</tr>
<tr>
<td>
<code>net</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceNetSpec">
KafkaSourceNetSpec
</a>
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.KafkaResourceSpec">
KafkaResourceSpec
</a>
</em>
</td>
<td>
<p>Resource limits and Request specifications of the Receive Adapter Deployment</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.KafkaSourceStatus">KafkaSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSource">KafkaSource</a>)
</p>
<p>
<p>KafkaSourceStatus defines the observed state of KafkaSource.</p>
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
</td>
</tr>
</tbody>
</table>
<<<<<<< HEAD
<h3 id="sources.knative.dev/v1alpha1.KafkaSourceTLSSpec">KafkaSourceTLSSpec
=======
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSASLSpec">KafkaSourceSASLSpec</a>,
<a href="#sources.knative.dev/v1alpha1.KafkaSourceTLSSpec">KafkaSourceTLSSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
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
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitHubSourceSpec">GitHubSourceSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
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
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
>>>>>>> 15673978d483a43af83f84279f409699774b4a97
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceNetSpec">KafkaSourceNetSpec</a>)
</p>
<p>
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
<code>enable</code></br>
<em>
bool
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>cert</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Cert is the Kubernetes secret containing the client certificate.</p>
</td>
</tr>
<tr>
<td>
<code>key</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Key is the Kubernetes secret containing the client key.</p>
</td>
</tr>
<tr>
<td>
<code>caCert</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SecretValueFromSource">
SecretValueFromSource
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>CACert is the Kubernetes secret containing the server CA cert.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.PrometheusSourceSpec">PrometheusSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PrometheusSource">PrometheusSource</a>)
</p>
<p>
<p>PrometheusSourceSpec defines the desired state of PrometheusSource</p>
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
in which the PrometheusSource exists.</p>
</td>
</tr>
<tr>
<td>
<code>serverURL</code></br>
<em>
string
</em>
</td>
<td>
<p>ServerURL is the URL of the Prometheus server</p>
</td>
</tr>
<tr>
<td>
<code>promQL</code></br>
<em>
string
</em>
</td>
<td>
<p>PromQL is the Prometheus query for this source</p>
</td>
</tr>
<tr>
<td>
<code>authTokenFile</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>The name of the file containing the authenication token</p>
</td>
</tr>
<tr>
<td>
<code>caCertConfigMap</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>The name of the config map containing the CA certificate of the
Prometheus service&rsquo;s signer.</p>
</td>
</tr>
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<p>A crontab-formatted schedule for running the PromQL query</p>
</td>
</tr>
<tr>
<td>
<code>step</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Query resolution step width in duration format or float number of seconds.
Prometheus duration strings are of the form [0-9]+[smhdwy].</p>
</td>
</tr>
<tr>
<td>
<code>sink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sink is a reference to an object that will resolve to a host
name to use as the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.PrometheusSourceStatus">PrometheusSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PrometheusSource">PrometheusSource</a>)
</p>
<p>
<p>PrometheusSourceStatus defines the observed state of PrometheusSource</p>
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
<code>SourceStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceStatus
</em>
</td>
<td>
<p>
(Members of <code>SourceStatus</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceStatus, which currently provides:
* ObservedGeneration - the &lsquo;Generation&rsquo; of the Service that was last
processed by the controller.
* Conditions - the latest available observations of a resource&rsquo;s current
state.
* SinkURI - the current active sink URI that has been configured for the
Source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.KafkaSourceSASLSpec">KafkaSourceSASLSpec</a>,
<a href="#sources.knative.dev/v1alpha1.KafkaSourceTLSSpec">KafkaSourceTLSSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
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
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitHubSourceSpec">GitHubSourceSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
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
<h3 id="sources.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.GitLabSourceSpec">GitLabSourceSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#secretkeyselector-v1-core">
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
on git commit <code>6ba61a66</code>.
</em></p>
