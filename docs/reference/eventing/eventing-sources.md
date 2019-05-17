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
<ul>
<li><a href="#GitHubSource">GitHubSource</a></li>
<li><a href="#GcpPubSubSource">GcpPubSubSource</a></li>
<li><a href="#KafkaSource">KafkaSource</a></li>
<li><a href="#CamelSource">CamelSource</a></li>
<li><a href="#AwsSqsSource">AwsSqsSource</a></li>
</ul>
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
<h3 id="GcpPubSubSource">GcpPubSubSource
</h3>
<p>
<p>GcpPubSubSource is the Schema for the gcppubsubsources API.</p>
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
<td><code>GcpPubSubSource</code></td>
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
<a href="#GcpPubSubSourceSpec">
GcpPubSubSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>gcpCredsSecret</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<p>GcpCredsSecret is the credential to use to poll the GCP PubSub Subscription. It is not used
to create or delete the Subscription, only to poll it. The value of the secret entry must be
a service account key in the JSON format (see
<a href="https://cloud.google.com/iam/docs/creating-managing-service-account-keys)">https://cloud.google.com/iam/docs/creating-managing-service-account-keys)</a>.</p>
</td>
</tr>
<tr>
<td>
<code>googleCloudProject</code></br>
<em>
string
</em>
</td>
<td>
<p>GoogleCloudProject is the ID of the Google Cloud Project that the PubSub Topic exists in.</p>
</td>
</tr>
<tr>
<td>
<code>topic</code></br>
<em>
string
</em>
</td>
<td>
<p>Topic is the ID of the GCP PubSub Topic to Subscribe to. It must be in the form of the
unique identifier within the project, not the entire name. E.g. it must be &lsquo;laconia&rsquo;, not
&lsquo;projects/my-gcp-project/topics/laconia&rsquo;.</p>
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
<code>transformer</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Transformer is a reference to an object that will resolve to a domain name to use as the transformer.</p>
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
<a href="#GcpPubSubSourceStatus">
GcpPubSubSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="GcpPubSubSourceSpec">GcpPubSubSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#GcpPubSubSource">GcpPubSubSource</a>)
</p>
<p>
<p>GcpPubSubSourceSpec defines the desired state of the GcpPubSubSource.</p>
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
<code>gcpCredsSecret</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#secretkeyselector-v1-core">
Kubernetes core/v1.SecretKeySelector
</a>
</em>
</td>
<td>
<p>GcpCredsSecret is the credential to use to poll the GCP PubSub Subscription. It is not used
to create or delete the Subscription, only to poll it. The value of the secret entry must be
a service account key in the JSON format (see
<a href="https://cloud.google.com/iam/docs/creating-managing-service-account-keys)">https://cloud.google.com/iam/docs/creating-managing-service-account-keys)</a>.</p>
</td>
</tr>
<tr>
<td>
<code>googleCloudProject</code></br>
<em>
string
</em>
</td>
<td>
<p>GoogleCloudProject is the ID of the Google Cloud Project that the PubSub Topic exists in.</p>
</td>
</tr>
<tr>
<td>
<code>topic</code></br>
<em>
string
</em>
</td>
<td>
<p>Topic is the ID of the GCP PubSub Topic to Subscribe to. It must be in the form of the
unique identifier within the project, not the entire name. E.g. it must be &lsquo;laconia&rsquo;, not
&lsquo;projects/my-gcp-project/topics/laconia&rsquo;.</p>
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
<code>transformer</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Transformer is a reference to an object that will resolve to a domain name to use as the transformer.</p>
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
<h3 id="GcpPubSubSourceStatus">GcpPubSubSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#GcpPubSubSource">GcpPubSubSource</a>)
</p>
<p>
<p>GcpPubSubSourceStatus defines the observed state of GcpPubSubSource.</p>
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
<p>SinkURI is the current active sink URI that has been configured for the GcpPubSubSource.</p>
</td>
</tr>
<tr>
<td>
<code>transformerUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>TransformerURI is the current active transformer URI that has been configured for the GcpPubSubSource.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h3 id="KafkaSource">KafkaSource
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
<td><code>KafkaSource</code></td>
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
<a href="#KafkaSourceSpec">
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
<a href="#KafkaSourceNetSpec">
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
<a href="#KafkaSourceStatus">
KafkaSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="KafkaSourceNetSpec">KafkaSourceNetSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#KafkaSourceSpec">KafkaSourceSpec</a>)
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
<a href="#KafkaSourceSASLSpec">
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
<a href="#KafkaSourceTLSSpec">
KafkaSourceTLSSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="KafkaSourceSASLSpec">KafkaSourceSASLSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#KafkaSourceNetSpec">KafkaSourceNetSpec</a>)
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
github.com/knative/eventing-sources/pkg/apis/sources/v1alpha1.SecretValueFromSource
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
github.com/knative/eventing-sources/pkg/apis/sources/v1alpha1.SecretValueFromSource
</em>
</td>
<td>
<em>(Optional)</em>
<p>Password is the Kubernetes secret containing the SASL password.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="KafkaSourceSpec">KafkaSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#KafkaSource">KafkaSource</a>)
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
<a href="#KafkaSourceNetSpec">
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
<h3 id="KafkaSourceStatus">KafkaSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#KafkaSource">KafkaSource</a>)
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
<p>SinkURI is the current active sink URI that has been configured for the KafkaSource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="KafkaSourceTLSSpec">KafkaSourceTLSSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#KafkaSourceNetSpec">KafkaSourceNetSpec</a>)
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
github.com/knative/eventing-sources/pkg/apis/sources/v1alpha1.SecretValueFromSource
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
github.com/knative/eventing-sources/pkg/apis/sources/v1alpha1.SecretValueFromSource
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
github.com/knative/eventing-sources/pkg/apis/sources/v1alpha1.SecretValueFromSource
</em>
</td>
<td>
<em>(Optional)</em>
<p>CACert is the Kubernetes secret containing the server CA cert.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h3 id="CamelSource">CamelSource
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
sources.eventing.knative.dev/v1alpha1
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
<a href="#CamelSourceSpec">
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
<a href="#CamelSourceOriginSpec">
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
<code>image</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Image is an optional base image used to run the source.</p>
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
<a href="#CamelSourceStatus">
CamelSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="CamelSourceOriginComponentSpec">CamelSourceOriginComponentSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CamelSourceOriginSpec">CamelSourceOriginSpec</a>)
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
<code>uri</code></br>
<em>
string
</em>
</td>
<td>
<p>URI is a Camel component URI to use as starting point (e.g. &ldquo;timer:tick?period=2s&rdquo;)</p>
</td>
</tr>
<tr>
<td>
<code>properties</code></br>
<em>
map[string]string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="CamelSourceOriginSpec">CamelSourceOriginSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CamelSourceSpec">CamelSourceSpec</a>)
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
<code>component</code></br>
<em>
<a href="#CamelSourceOriginComponentSpec">
CamelSourceOriginComponentSpec
</a>
</em>
</td>
<td>
<p>Component is a kind of source that directly references a Camel component</p>
</td>
</tr>
</tbody>
</table>
<h3 id="CamelSourceSpec">CamelSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CamelSource">CamelSource</a>)
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
<a href="#CamelSourceOriginSpec">
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
<code>image</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Image is an optional base image used to run the source.</p>
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
<h3 id="CamelSourceStatus">CamelSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#CamelSource">CamelSource</a>)
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
<p>SinkURI is the current active sink URI that has been configured for the CamelSource.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
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
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>b6cdf390</code>.
</em></p>
