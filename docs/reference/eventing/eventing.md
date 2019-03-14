<p>Packages:</p>
<ul>
<li>
<a href="#duck.knative.dev">duck.knative.dev</a>
</li>
<li>
<a href="#eventing.knative.dev">eventing.knative.dev</a>
</li>
</ul>
<h2 id="duck.knative.dev">duck.knative.dev</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul></ul>
<h3 id="Channel">Channel
</h3>
<p>
<p>Channel is a skeleton type wrapping Subscribable in the manner we expect resource writers
defining compatible resources to embed it. We will typically use this type to deserialize
Channel ObjectReferences and access the Subscription data.  This is not a real resource.</p>
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
<a href="#ChannelSpec">
ChannelSpec
</a>
</em>
</td>
<td>
<p>ChannelSpec is the part where Subscribable object is
configured as to be compatible with Subscribable contract.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>subscribable</code></br>
<em>
<a href="#Subscribable">
Subscribable
</a>
</em>
</td>
<td>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelSpec">ChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Channel">Channel</a>)
</p>
<p>
<p>ChannelSpec shows how we expect folks to embed Subscribable in their Spec field.</p>
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
<a href="#Subscribable">
Subscribable
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelSubscriberSpec">ChannelSubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Subscribable">Subscribable</a>)
</p>
<p>
<p>ChannelSubscriberSpec defines a single subscriber to a Channel.
Ref is a reference to the Subscription this ChannelSubscriberSpec was created for
SubscriberURI is the endpoint for the subscriber
ReplyURI is the endpoint for the reply
At least one of SubscriberURI and ReplyURI must be present</p>
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
<code>ref</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
<tr>
<td>
<code>subscriberURI</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
<tr>
<td>
<code>replyURI</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="Subscribable">Subscribable
</h3>
<p>
(<em>Appears on:</em>
<a href="#ChannelSpec">ChannelSpec</a>, 
<a href="#ChannelSpec">ChannelSpec</a>)
</p>
<p>
<p>Subscribable is the schema for the subscribable portion of the spec
section of the resource.</p>
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
<code>subscribers</code></br>
<em>
<a href="#ChannelSubscriberSpec">
[]ChannelSubscriberSpec
</a>
</em>
</td>
<td>
<p>TODO: What is actually required here for Channel spec.
This is the list of subscriptions for this channel.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="eventing.knative.dev">eventing.knative.dev</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#Channel">Channel</a>
</li><li>
<a href="#ClusterChannelProvisioner">ClusterChannelProvisioner</a>
</li><li>
<a href="#Subscription">Subscription</a>
</li></ul>
<h3 id="Channel">Channel
</h3>
<p>
<p>Channel is an abstract resource that implements the Addressable contract.
The Provisioner provisions infrastructure to accepts events and
deliver to Subscriptions.</p>
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
eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Channel</code></td>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#ChannelSpec">
ChannelSpec
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
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
<tr>
<td>
<code>provisioner</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Provisioner defines the name of the Provisioner backing this channel.</p>
</td>
</tr>
<tr>
<td>
<code>arguments</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Arguments defines the arguments to pass to the Provisioner which
provisions this Channel.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
<a href="#Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#ChannelStatus">
ChannelStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Channel. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ClusterChannelProvisioner">ClusterChannelProvisioner
</h3>
<p>
<p>ClusterChannelProvisioner encapsulates a provisioning strategy for the
backing resources required to realize a particular resource type.</p>
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
eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>ClusterChannelProvisioner</code></td>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#ClusterChannelProvisionerSpec">
ClusterChannelProvisionerSpec
</a>
</em>
</td>
<td>
<p>Spec defines the Types provisioned by this Provisioner.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#ClusterChannelProvisionerStatus">
ClusterChannelProvisionerStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status is the current status of the Provisioner.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="Subscription">Subscription
</h3>
<p>
<p>Subscription routes events received on a Channel to a DNS name and
corresponds to the subscriptions.channels.knative.dev CRD.</p>
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
eventing.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Subscription</code></td>
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
<a href="#SubscriptionSpec">
SubscriptionSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
<tr>
<td>
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Reference to a channel that will be used to create the subscription
for receiving events. The channel must have spec.subscriptions
list which will then be modified accordingly.</p>
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
Kind must be &ldquo;Channel&rdquo; and APIVersion must be
&ldquo;eventing.knative.dev/v1alpha1&rdquo;</p>
<p>This field is immutable. We have no good answer on what happens to
the events that are currently in the channel being consumed from
and what the semantics there should be. For now, you can always
delete the Subscription and recreate it to point to a different
channel, giving the user more control over what semantics should
be used (drain the channel first, possibly have events dropped,
etc.)</p>
</td>
</tr>
<tr>
<td>
<code>subscriber</code></br>
<em>
<a href="#SubscriberSpec">
SubscriberSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a channel as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
<a href="#ReplyStrategy">
ReplyStrategy
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#SubscriptionStatus">
SubscriptionStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelProvisionerDefaulter">ChannelProvisionerDefaulter
</h3>
<p>
<p>ChannelProvisionerDefaulter sets the default Provisioner and Arguments on Channels that do not
specify any Provisioner.</p>
</p>
<h3 id="ChannelSpec">ChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Channel">Channel</a>)
</p>
<p>
<p>ChannelSpec specifies the Provisioner backing a channel and the configuration
arguments for a Channel.</p>
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
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
<tr>
<td>
<code>provisioner</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Provisioner defines the name of the Provisioner backing this channel.</p>
</td>
</tr>
<tr>
<td>
<code>arguments</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Arguments defines the arguments to pass to the Provisioner which
provisions this Channel.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
<a href="#Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelStatus">ChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Channel">Channel</a>)
</p>
<p>
<p>ChannelStatus represents the current state of a Channel.</p>
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
<code>observedGeneration</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ObservedGeneration is the most recent generation observed for this Channel.
It corresponds to the Channel&rsquo;s generation, which is updated on mutation by
the API Server.
TODO: The above comment is only true once
<a href="https://github.com/kubernetes/kubernetes/issues/58778">https://github.com/kubernetes/kubernetes/issues/58778</a> is fixed.</p>
</td>
</tr>
<tr>
<td>
<code>address</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Addressable">
github.com/knative/pkg/apis/duck/v1alpha1.Addressable
</a>
</em>
</td>
<td>
<p>Channel is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {channel}.{namespace}.svc.cluster.local</p>
</td>
</tr>
<tr>
<td>
<code>conditions</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Conditions">
github.com/knative/pkg/apis/duck/v1alpha1.Conditions
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Represents the latest available observations of a channel&rsquo;s current state.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ClusterChannelProvisionerSpec">ClusterChannelProvisionerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#ClusterChannelProvisioner">ClusterChannelProvisioner</a>)
</p>
<p>
<p>ClusterChannelProvisionerSpec is the spec for a ClusterChannelProvisioner resource.</p>
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
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ClusterChannelProvisionerStatus">ClusterChannelProvisionerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#ClusterChannelProvisioner">ClusterChannelProvisioner</a>)
</p>
<p>
<p>ClusterChannelProvisionerStatus is the status for a ClusterChannelProvisioner resource</p>
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
<code>conditions</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Conditions">
github.com/knative/pkg/apis/duck/v1alpha1.Conditions
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Conditions holds the state of a cluster provisioner at a point in time.</p>
</td>
</tr>
<tr>
<td>
<code>observedGeneration</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ObservedGeneration is the &lsquo;Generation&rsquo; of the ClusterChannelProvisioner that
was last reconciled by the controller.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ReplyStrategy">ReplyStrategy
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscriptionSpec">SubscriptionSpec</a>)
</p>
<p>
<p>ReplyStrategy specifies the handling of the SubscriberSpec&rsquo;s returned replies.
If no SubscriberSpec is specified, the identity function is assumed.</p>
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
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>This object must be a Channel.</p>
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
Kind must be &ldquo;Channel&rdquo; and APIVersion must be
&ldquo;eventing.knative.dev/v1alpha1&rdquo;</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriberSpec">SubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscriptionSpec">SubscriptionSpec</a>)
</p>
<p>
<p>SubscriberSpec specifies the reference to an object that&rsquo;s expected to
provide the resolved target of the action.
Currently we inspect the objects Status and see if there&rsquo;s a predefined
Status field that we will then use to dispatch events to be processed by
the target. Currently must resolve to a k8s service or Istio virtual
service.
Note that in the future we should try to utilize subresources (/resolve ?) to
make this cleaner, but CRDs do not support subresources yet, so we need
to rely on a specified Status field today. By relying on this behaviour
we can utilize a dynamic client instead of having to understand all
kinds of different types of objects. As long as they adhere to this
particular contract, they can be used as a Target.</p>
<p>This ensures that we can support external targets and for ease of use
we also allow for an URI to be specified.
There of course is also a requirement for the resolved SubscriberSpec to
behave properly at the data plane level.
TODO: Add a pointer to a real spec for this.
For now, this means: Receive an event payload, and respond with one of:
success and an optional response event, or failure.
Delivery failures may be retried by the channel</p>
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
<code>ref</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reference to an object that will be used to find the target
endpoint, which should implement the Addressable duck type.
For example, this could be a reference to a Route resource
or a Knative Service resource.
TODO: Specify the required fields the target object must
have in the status.
You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name</p>
</td>
</tr>
<tr>
<td>
<code>dnsName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reference to a &lsquo;known&rsquo; endpoint where no resolving is done.
<a href="http://k8s-service">http://k8s-service</a> for example
<a href="http://myexternalhandler.example.com/foo/bar">http://myexternalhandler.example.com/foo/bar</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriptionSpec">SubscriptionSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Subscription">Subscription</a>)
</p>
<p>
<p>SubscriptionSpec specifies the Channel for incoming events, a Subscriber target
for processing those events and where to put the result of the processing. Only
From (where the events are coming from) is always required. You can optionally
only Process the events (results in no output events) by leaving out the Result.
You can also perform an identity transformation on the invoming events by leaving
out the Subscriber and only specifying Result.</p>
<p>The following are all valid specifications:
channel &ndash;[subscriber]&ndash;&gt; reply
Sink, no outgoing events:
channel &ndash; subscriber
no-op function (identity transformation):
channel &ndash;&gt; reply</p>
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
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TODO By enabling the status subresource metadata.generation should increment
thus making this property obsolete.</p>
<p>We should be able to drop this property with a CRD conversion webhook
in the future</p>
</td>
</tr>
<tr>
<td>
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Reference to a channel that will be used to create the subscription
for receiving events. The channel must have spec.subscriptions
list which will then be modified accordingly.</p>
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
Kind must be &ldquo;Channel&rdquo; and APIVersion must be
&ldquo;eventing.knative.dev/v1alpha1&rdquo;</p>
<p>This field is immutable. We have no good answer on what happens to
the events that are currently in the channel being consumed from
and what the semantics there should be. For now, you can always
delete the Subscription and recreate it to point to a different
channel, giving the user more control over what semantics should
be used (drain the channel first, possibly have events dropped,
etc.)</p>
</td>
</tr>
<tr>
<td>
<code>subscriber</code></br>
<em>
<a href="#SubscriberSpec">
SubscriberSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a channel as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
<a href="#ReplyStrategy">
ReplyStrategy
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriptionStatus">SubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Subscription">Subscription</a>)
</p>
<p>
<p>SubscriptionStatus (computed) for a subscription</p>
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
<code>conditions</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Conditions">
github.com/knative/pkg/apis/duck/v1alpha1.Conditions
</a>
</em>
</td>
<td>
<p>Represents the latest available observations of a subscription&rsquo;s current state.</p>
</td>
</tr>
<tr>
<td>
<code>physicalSubscription</code></br>
<em>
<a href="#SubscriptionStatusPhysicalSubscription">
SubscriptionStatusPhysicalSubscription
</a>
</em>
</td>
<td>
<p>PhysicalSubscription is the fully resolved values that this Subscription represents.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriptionStatusPhysicalSubscription">SubscriptionStatusPhysicalSubscription
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscriptionStatus">SubscriptionStatus</a>)
</p>
<p>
<p>SubscriptionStatusPhysicalSubscription represents the fully resolved values for this
Subscription.</p>
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
<code>subscriberURI</code></br>
<em>
string
</em>
</td>
<td>
<p>SubscriberURI is the fully resolved URI for spec.subscriber.</p>
</td>
</tr>
<tr>
<td>
<code>replyURI</code></br>
<em>
string
</em>
</td>
<td>
<p>ReplyURI is the fully resolved URI for the spec.reply.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>4712e3a4</code>.
</em></p>
