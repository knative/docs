<p>Packages:</p>
<ul>
<li>
<a href="#duck.knative.dev">duck.knative.dev</a>
</li>
<li>
<a href="#eventing.knative.dev">eventing.knative.dev</a>
</li>
<li>
<a href="#messaging.knative.dev">messaging.knative.dev</a>
</li>
<li>
<a href="#sources.eventing.knative.dev">sources.eventing.knative.dev</a>
</li>
</ul>
<h2 id="duck.knative.dev">duck.knative.dev</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#Channelable">Channelable</a>
</li><li>
<a href="#SubscribableType">SubscribableType</a>
</li></ul>
<h3 id="Channelable">Channelable
</h3>
<p>
<p>Channelable is a skeleton type wrapping Subscribable and Addressable in the manner we expect resource writers
defining compatible resources to embed it. We will typically use this type to deserialize
Channelable ObjectReferences and access their subscription and address data.  This is not a real resource.</p>
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
duck.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Channelable</code></td>
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
<a href="#ChannelableSpec">
ChannelableSpec
</a>
</em>
</td>
<td>
<p>Spec is the part where the Channelable fulfills the Subscribable contract.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>SubscribableTypeSpec</code></br>
<em>
<a href="#SubscribableTypeSpec">
SubscribableTypeSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeSpec</code> are embedded into this type.)
</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#ChannelableStatus">
ChannelableStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscribableType">SubscribableType
</h3>
<p>
<p>SubscribableType is a skeleton type wrapping Subscribable in the manner we expect resource writers
defining compatible resources to embed it. We will typically use this type to deserialize
SubscribableType ObjectReferences and access the Subscription data.  This is not a real resource.</p>
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
duck.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>SubscribableType</code></td>
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
<a href="#SubscribableTypeSpec">
SubscribableTypeSpec
</a>
</em>
</td>
<td>
<p>SubscribableTypeSpec is the part where Subscribable object is
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
<tr>
<td>
<code>status</code></br>
<em>
<a href="#SubscribableTypeStatus">
SubscribableTypeStatus
</a>
</em>
</td>
<td>
<p>SubscribableTypeStatus is the part where SubscribableStatus object is
configured as to be compatible with Subscribable contract.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelableSpec">ChannelableSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Channelable">Channelable</a>)
</p>
<p>
<p>ChannelableSpec contains Spec of the Channelable object</p>
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
<code>SubscribableTypeSpec</code></br>
<em>
<a href="#SubscribableTypeSpec">
SubscribableTypeSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeSpec</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelableStatus">ChannelableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Channelable">Channelable</a>)
</p>
<p>
<p>ChannelableStatus contains the Status of a Channelable object.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#AddressStatus">
github.com/knative/pkg/apis/duck/v1alpha1.AddressStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>AddressStatus is the part where the Channelable fulfills the Addressable contract.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#SubscribableTypeStatus">
SubscribableTypeStatus
</a>
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
<h3 id="Subscribable">Subscribable
</h3>
<p>
(<em>Appears on:</em>
<a href="#ChannelSpec">ChannelSpec</a>, 
<a href="#InMemoryChannelSpec">InMemoryChannelSpec</a>, 
<a href="#SubscribableTypeSpec">SubscribableTypeSpec</a>)
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
<a href="#SubscriberSpec">
[]SubscriberSpec
</a>
</em>
</td>
<td>
<p>This is the list of subscriptions for this subscribable.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscribableStatus">SubscribableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscribableTypeStatus">SubscribableTypeStatus</a>)
</p>
<p>
<p>SubscribableStatus is the schema for the subscribable&rsquo;s status portion of the status
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
<a href="#SubscriberStatus">
[]SubscriberStatus
</a>
</em>
</td>
<td>
<p>This is the list of subscription&rsquo;s statuses for this channel.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscribableTypeSpec">SubscribableTypeSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscribableType">SubscribableType</a>, 
<a href="#ChannelableSpec">ChannelableSpec</a>)
</p>
<p>
<p>SubscribableTypeSpec shows how we expect folks to embed Subscribable in their Spec field.</p>
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
<h3 id="SubscribableTypeStatus">SubscribableTypeStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscribableType">SubscribableType</a>, 
<a href="#ChannelStatus">ChannelStatus</a>, 
<a href="#ChannelableStatus">ChannelableStatus</a>, 
<a href="#InMemoryChannelStatus">InMemoryChannelStatus</a>)
</p>
<p>
<p>SubscribableTypeStatus shows how we expect folks to embed Subscribable in their Status field.</p>
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
<code>subscribablestatus</code></br>
<em>
<a href="#SubscribableStatus">
SubscribableStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriberSpec">SubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Subscribable">Subscribable</a>)
</p>
<p>
<p>SubscriberSpec defines a single subscriber to a Subscribable.
Ref is a reference to the Subscription this SubscriberSpec was created for
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
<p>Deprecated: use UID.</p>
</td>
</tr>
<tr>
<td>
<code>uid</code></br>
<em>
k8s.io/apimachinery/pkg/types.UID
</em>
</td>
<td>
<em>(Optional)</em>
<p>UID is used to understand the origin of the subscriber.</p>
</td>
</tr>
<tr>
<td>
<code>generation</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>Generation of the origin of the subscriber with uid:UID.</p>
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
<h3 id="SubscriberStatus">SubscriberStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#SubscribableStatus">SubscribableStatus</a>)
</p>
<p>
<p>SubscriberStatus defines the status of a single subscriber to a Channel.</p>
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
<code>uid</code></br>
<em>
k8s.io/apimachinery/pkg/types.UID
</em>
</td>
<td>
<em>(Optional)</em>
<p>UID is used to understand the origin of the subscriber.</p>
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
<p>Generation of the origin of the subscriber with uid:UID.</p>
</td>
</tr>
<tr>
<td>
<code>ready</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#conditionstatus-v1-core">
Kubernetes core/v1.ConditionStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status of the subscriber.</p>
</td>
</tr>
<tr>
<td>
<code>message</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>A human readable message indicating details of Ready status.</p>
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
<a href="#Broker">Broker</a>
</li><li>
<a href="#Channel">Channel</a>
</li><li>
<a href="#ClusterChannelProvisioner">ClusterChannelProvisioner</a>
</li><li>
<a href="#EventType">EventType</a>
</li><li>
<a href="#Subscription">Subscription</a>
</li><li>
<a href="#Trigger">Trigger</a>
</li></ul>
<h3 id="Broker">Broker
</h3>
<p>
<p>Broker collects a pool of events that are consumable using Triggers. Brokers
provide a well-known endpoint for event delivery that senders can use with
minimal knowledge of the event routing strategy. Receivers use Triggers to
request delivery of events from a Broker&rsquo;s pool to a specific URL or
Addressable endpoint.</p>
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
<td><code>Broker</code></td>
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
<a href="#BrokerSpec">
BrokerSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Broker.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#ChannelSpec">
ChannelSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedChannelTemplate, if specified will be used to create all the Channels used internally by the
Broker. Only Provisioner and Arguments may be specified. If left unspecified, the default
Channel for the namespace will be used.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplateSpec</code></br>
<em>
<a href="#ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create all the Channels used internally by the
Broker.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#BrokerStatus">
BrokerStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Broker. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
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
<h3 id="EventType">EventType
</h3>
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
<td><code>EventType</code></td>
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
<a href="#EventTypeSpec">
EventTypeSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the EventType.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>type</code></br>
<em>
string
</em>
</td>
<td>
<p>Type represents the CloudEvents type. It is authoritative.</p>
</td>
</tr>
<tr>
<td>
<code>source</code></br>
<em>
string
</em>
</td>
<td>
<p>Source is a URI, it represents the CloudEvents source.</p>
</td>
</tr>
<tr>
<td>
<code>schema</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Schema is a URI, it represents the CloudEvents schemaurl extension attribute.
It may be a JSON schema, a protobuf schema, etc. It is optional.</p>
</td>
</tr>
<tr>
<td>
<code>broker</code></br>
<em>
string
</em>
</td>
<td>
<p>Broker refers to the Broker that can provide the EventType.</p>
</td>
</tr>
<tr>
<td>
<code>description</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Description is an optional field used to describe the EventType, in any meaningful way.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#EventTypeStatus">
EventTypeStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the EventType.
This data may be out of date.</p>
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
<h3 id="Trigger">Trigger
</h3>
<p>
<p>Trigger represents a request to have events delivered to a consumer from a
Broker&rsquo;s event pool.</p>
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
<td><code>Trigger</code></td>
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
<a href="#TriggerSpec">
TriggerSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Trigger.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>broker</code></br>
<em>
string
</em>
</td>
<td>
<p>Broker is the broker that this trigger receives events from. If not specified, will default
to &lsquo;default&rsquo;.</p>
</td>
</tr>
<tr>
<td>
<code>filter</code></br>
<em>
<a href="#TriggerFilter">
TriggerFilter
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Filter is the filter to apply against all events from the Broker. Only events that pass this
filter will be sent to the Subscriber. If not specified, will default to allowing all events.</p>
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
<p>Subscriber is the addressable that receives events from the Broker that pass the Filter. It
is required.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#TriggerStatus">
TriggerStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Trigger. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="BrokerSpec">BrokerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Broker">Broker</a>)
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
<code>channelTemplate</code></br>
<em>
<a href="#ChannelSpec">
ChannelSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedChannelTemplate, if specified will be used to create all the Channels used internally by the
Broker. Only Provisioner and Arguments may be specified. If left unspecified, the default
Channel for the namespace will be used.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplateSpec</code></br>
<em>
<a href="#ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create all the Channels used internally by the
Broker.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="BrokerStatus">BrokerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Broker">Broker</a>)
</p>
<p>
<p>BrokerStatus represents the current state of a Broker.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<code>address</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#Addressable">
github.com/knative/pkg/apis/duck/v1alpha1.Addressable
</a>
</em>
</td>
<td>
<p>Broker is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {broker}-router.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>triggerChannel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>TriggerChannel is an objectref to the object for the TriggerChannel</p>
</td>
</tr>
<tr>
<td>
<code>IngressChannel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>IngressChannel is an objectref to the object for the IngressChannel</p>
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
<a href="#Channel">Channel</a>, 
<a href="#BrokerSpec">BrokerSpec</a>)
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
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<p>It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>internal</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Internal is status unique to each ClusterChannelProvisioner.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#SubscribableTypeStatus">
SubscribableTypeStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeStatus</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelTemplateSpec">ChannelTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#BrokerSpec">BrokerSpec</a>)
</p>
<p>
<p>This should be duck so that Broker can also use this</p>
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
<code>spec</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec defines the Spec to use for each channel created. Passed
in verbatim to the Channel CRD as Spec section.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>Raw</code></br>
<em>
[]byte
</em>
</td>
<td>
<p>Raw is the underlying serialization of this object.</p>
<p>TODO: Determine how to detect ContentType and ContentEncoding of &lsquo;Raw&rsquo; data.</p>
</td>
</tr>
<tr>
<td>
<code>-</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.Object
</em>
</td>
<td>
<p>Object can hold a representation of this extension - useful for working with versioned
structs.</p>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelTemplateSpecInternal">ChannelTemplateSpecInternal
</h3>
<p>
<p>Internal version of ChannelTemplateSpec that includes ObjectMeta so that
we can easily create new Channels off of it.</p>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec defines the Spec to use for each channel created. Passed
in verbatim to the Channel CRD as Spec section.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>Raw</code></br>
<em>
[]byte
</em>
</td>
<td>
<p>Raw is the underlying serialization of this object.</p>
<p>TODO: Determine how to detect ContentType and ContentEncoding of &lsquo;Raw&rsquo; data.</p>
</td>
</tr>
<tr>
<td>
<code>-</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.Object
</em>
</td>
<td>
<p>Object can hold a representation of this extension - useful for working with versioned
structs.</p>
</td>
</tr>
</table>
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
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
</tbody>
</table>
<h3 id="EventTypeSpec">EventTypeSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#EventType">EventType</a>)
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
<code>type</code></br>
<em>
string
</em>
</td>
<td>
<p>Type represents the CloudEvents type. It is authoritative.</p>
</td>
</tr>
<tr>
<td>
<code>source</code></br>
<em>
string
</em>
</td>
<td>
<p>Source is a URI, it represents the CloudEvents source.</p>
</td>
</tr>
<tr>
<td>
<code>schema</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Schema is a URI, it represents the CloudEvents schemaurl extension attribute.
It may be a JSON schema, a protobuf schema, etc. It is optional.</p>
</td>
</tr>
<tr>
<td>
<code>broker</code></br>
<em>
string
</em>
</td>
<td>
<p>Broker refers to the Broker that can provide the EventType.</p>
</td>
</tr>
<tr>
<td>
<code>description</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Description is an optional field used to describe the EventType, in any meaningful way.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="EventTypeStatus">EventTypeStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#EventType">EventType</a>)
</p>
<p>
<p>EventTypeStatus represents the current state of a EventType.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
</tbody>
</table>
<h3 id="HasSpec">HasSpec
</h3>
<p>
</p>
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
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
The resource pointed by this ObjectReference must meet the Addressable contract
with a reference to the Addressable duck type. If the resource does not meet this contract,
it will be reflected in the Subscription&rsquo;s status.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SubscriberSpec">SubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#SequenceSpec">SequenceSpec</a>, 
<a href="#SubscriptionSpec">SubscriptionSpec</a>, 
<a href="#TriggerSpec">TriggerSpec</a>)
</p>
<p>
<p>SubscriberSpec specifies the reference to an object that&rsquo;s expected to
provide the resolved target of the action.
Currently we inspect the objects Status and see if there&rsquo;s a predefined
Status field that we will then use to dispatch events to be processed by
the target. Currently must resolve to a k8s service.
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
<p>Deprecated: Use URI instead.
Reference to a &lsquo;known&rsquo; endpoint where no resolving is done.
<a href="http://k8s-service">http://k8s-service</a> for example
<a href="http://myexternalhandler.example.com/foo/bar">http://myexternalhandler.example.com/foo/bar</a></p>
</td>
</tr>
<tr>
<td>
<code>uri</code></br>
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
You can also perform an identity transformation on the incoming events by leaving
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
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<h3 id="TriggerFilter">TriggerFilter
</h3>
<p>
(<em>Appears on:</em>
<a href="#TriggerSpec">TriggerSpec</a>)
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
<code>sourceAndType</code></br>
<em>
<a href="#TriggerFilterSourceAndType">
TriggerFilterSourceAndType
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="TriggerFilterSourceAndType">TriggerFilterSourceAndType
</h3>
<p>
(<em>Appears on:</em>
<a href="#TriggerFilter">TriggerFilter</a>)
</p>
<p>
<p>TriggerFilterSourceAndType filters events based on exact matches on the cloud event&rsquo;s type and
source attributes. Only exact matches will pass the filter. Either or both type and source can
use the value &lsquo;Any&rsquo; to indicate all strings match.</p>
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
<code>type</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>source</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="TriggerSpec">TriggerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Trigger">Trigger</a>)
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
<code>broker</code></br>
<em>
string
</em>
</td>
<td>
<p>Broker is the broker that this trigger receives events from. If not specified, will default
to &lsquo;default&rsquo;.</p>
</td>
</tr>
<tr>
<td>
<code>filter</code></br>
<em>
<a href="#TriggerFilter">
TriggerFilter
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Filter is the filter to apply against all events from the Broker. Only events that pass this
filter will be sent to the Subscriber. If not specified, will default to allowing all events.</p>
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
<p>Subscriber is the addressable that receives events from the Broker that pass the Filter. It
is required.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="TriggerStatus">TriggerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Trigger">Trigger</a>)
</p>
<p>
<p>TriggerStatus represents the current state of a Trigger.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<code>subscriberURI</code></br>
<em>
string
</em>
</td>
<td>
<p>SubscriberURI is the resolved URI of the receiver for this Trigger.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="messaging.knative.dev">messaging.knative.dev</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#InMemoryChannel">InMemoryChannel</a>
</li></ul>
<h3 id="InMemoryChannel">InMemoryChannel
</h3>
<p>
<p>InMemoryChannel is a resource representing an in memory channel</p>
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
<td><code>InMemoryChannel</code></td>
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
<a href="#InMemoryChannelSpec">
InMemoryChannelSpec
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
<a href="#InMemoryChannelStatus">
InMemoryChannelStatus
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
<h3 id="ChannelTemplateSpec">ChannelTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#SequenceSpec">SequenceSpec</a>)
</p>
<p>
<p>This should be duck so that Broker can also use this</p>
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
<code>spec</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec defines the Spec to use for each channel created. Passed
in verbatim to the Channel CRD as Spec section.</p>
<br/>
<br/>
<table>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="ChannelTemplateSpecInternal">ChannelTemplateSpecInternal
</h3>
<p>
<p>Internal version of ChannelTemplateSpec that includes ObjectMeta so that
we can easily create new Channels off of it.</p>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec defines the Spec to use for each channel created. Passed
in verbatim to the Channel CRD as Spec section.</p>
<br/>
<br/>
<table>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="InMemoryChannelSpec">InMemoryChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#InMemoryChannel">InMemoryChannel</a>)
</p>
<p>
<p>InMemoryChannelSpec defines which subscribers have expressed interest in
receiving events from this InMemoryChannel.
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
<h3 id="InMemoryChannelStatus">InMemoryChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#InMemoryChannel">InMemoryChannel</a>)
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
<code>Status</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#AddressStatus">
github.com/knative/pkg/apis/duck/v1alpha1.AddressStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>InMemoryChannel is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#SubscribableTypeStatus">
SubscribableTypeStatus
</a>
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
<h3 id="Sequence">Sequence
</h3>
<p>
<p>Sequence defines a sequence of Subscribers that will be wired in
series through Channels and Subscriptions.</p>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#SequenceSpec">
SequenceSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Sequence.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="#SubscriberSpec">
[]SubscriberSpec
</a>
</em>
</td>
<td>
<p>Steps is the list of Subscribers (processors / functions) that will be called in the order
provided.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name</p>
<p>The resource pointed by this ObjectReference must meet the Addressable contract
with a reference to the Addressable duck type. If the resource does not meet this contract,
it will be reflected in the Subscription&rsquo;s status.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#SequenceStatus">
SequenceStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Sequence. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SequenceChannelStatus">SequenceChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#SequenceStatus">SequenceStatus</a>)
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
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Channel is the reference to the underlying channel.</p>
</td>
</tr>
<tr>
<td>
<code>ready</code></br>
<em>
github.com/knative/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Channel is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SequenceSpec">SequenceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#Sequence">Sequence</a>)
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
<code>steps</code></br>
<em>
<a href="#SubscriberSpec">
[]SubscriberSpec
</a>
</em>
</td>
<td>
<p>Steps is the list of Subscribers (processors / functions) that will be called in the order
provided.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
<p>You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name</p>
<p>The resource pointed by this ObjectReference must meet the Addressable contract
with a reference to the Addressable duck type. If the resource does not meet this contract,
it will be reflected in the Subscription&rsquo;s status.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SequenceStatus">SequenceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#Sequence">Sequence</a>)
</p>
<p>
<p>SequenceStatus represents the current state of a Sequence.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
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
<code>SubscriptionStatuses</code></br>
<em>
<a href="#SequenceSubscriptionStatus">
[]SequenceSubscriptionStatus
</a>
</em>
</td>
<td>
<p>SubscriptionStatuses is an array of corresponding Subscription statuses.
Matches the Spec.Steps array in the order.</p>
</td>
</tr>
<tr>
<td>
<code>ChannelStatuses</code></br>
<em>
<a href="#SequenceChannelStatus">
[]SequenceChannelStatus
</a>
</em>
</td>
<td>
<p>ChannelStatuses is an array of corresponding Channel statuses.
Matches the Spec.Steps array in the order.</p>
</td>
</tr>
<tr>
<td>
<code>AddressStatus</code></br>
<em>
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1alpha1#AddressStatus">
github.com/knative/pkg/apis/duck/v1alpha1.AddressStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>AddressStatus is the starting point to this Sequence. Sending to this
will target the first subscriber.
It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
</tbody>
</table>
<h3 id="SequenceSubscriptionStatus">SequenceSubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#SequenceStatus">SequenceStatus</a>)
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
<code>subscription</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Subscription is the reference to the underlying Subscription.</p>
</td>
</tr>
<tr>
<td>
<code>ready</code></br>
<em>
github.com/knative/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Subscription is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="sources.eventing.knative.dev">sources.eventing.knative.dev</h2>
<p>
<p>Package v1alpha1 contains API Schema definitions for the sources v1alpha1 API group</p>
</p>
Resource Types:
<ul><li>
<a href="#ApiServerSource">ApiServerSource</a>
</li><li>
<a href="#ContainerSource">ContainerSource</a>
</li><li>
<a href="#CronJobSource">CronJobSource</a>
</li></ul>
<h3 id="ApiServerSource">ApiServerSource
</h3>
<p>
<p>ApiServerSource is the Schema for the apiserversources API</p>
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
<td><code>ApiServerSource</code></td>
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
<a href="#ApiServerSourceSpec">
ApiServerSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#ApiServerResource">
[]ApiServerResource
</a>
</em>
</td>
<td>
<p>Resources is the list of resources to watch</p>
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
<tr>
<td>
<code>mode</code></br>
<em>
string
</em>
</td>
<td>
<p>Mode is the mode the receive adapter controller runs under: Ref or Resource.
<code>Ref</code> sends only the reference to the resource.
<code>Resource</code> send the full resource.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#ApiServerSourceStatus">
ApiServerSourceStatus
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
<code>template</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#podtemplatespec-v1-core">
Kubernetes core/v1.PodTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template describes the pods that will be created</p>
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
<p>DeprecatedImage is the image to run inside of the container.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedArgs are passed to the ContainerSpec as they are.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedEnv is the list of environment variables to set in the container.
Cannot be updated.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedServiceAccountName is the name of the ServiceAccount to use to run this
source.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#CronJobResourceSpec">
CronJobResourceSpec
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
<h3 id="ApiServerResource">ApiServerResource
</h3>
<p>
(<em>Appears on:</em>
<a href="#ApiServerSourceSpec">ApiServerSourceSpec</a>)
</p>
<p>
<p>ApiServerResource defines the resource to watch</p>
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
<em>
string
</em>
</td>
<td>
<p>API version of the resource to watch.</p>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
<em>
string
</em>
</td>
<td>
<p>Kind of the resource to watch.
More info: <a href="https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds">https://git.k8s.io/community/contributors/devel/api-conventions.md#types-kinds</a></p>
</td>
</tr>
<tr>
<td>
<code>controller</code></br>
<em>
bool
</em>
</td>
<td>
<p>If true, send an event referencing the object controlling the resource</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ApiServerSourceSpec">ApiServerSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#ApiServerSource">ApiServerSource</a>)
</p>
<p>
<p>ApiServerSourceSpec defines the desired state of ApiServerSource</p>
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
<code>resources</code></br>
<em>
<a href="#ApiServerResource">
[]ApiServerResource
</a>
</em>
</td>
<td>
<p>Resources is the list of resources to watch</p>
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
<tr>
<td>
<code>mode</code></br>
<em>
string
</em>
</td>
<td>
<p>Mode is the mode the receive adapter controller runs under: Ref or Resource.
<code>Ref</code> sends only the reference to the resource.
<code>Resource</code> send the full resource.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="ApiServerSourceStatus">ApiServerSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#ApiServerSource">ApiServerSource</a>)
</p>
<p>
<p>ApiServerSourceStatus defines the observed state of ApiServerSource</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<code>sinkUri</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SinkURI is the current active sink URI that has been configured for the ApiServerSource.</p>
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
<code>template</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#podtemplatespec-v1-core">
Kubernetes core/v1.PodTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template describes the pods that will be created</p>
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
<p>DeprecatedImage is the image to run inside of the container.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedArgs are passed to the ContainerSpec as they are.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedEnv is the list of environment variables to set in the container.
Cannot be updated.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<p>DeprecatedServiceAccountName is the name of the ServiceAccount to use to run this
source.
This field is to be deprecated. Use <code>Template</code> instead.
When <code>Template</code> is set, this field is ignored.</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<h3 id="CronJobLimitsSpec">CronJobLimitsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CronJobResourceSpec">CronJobResourceSpec</a>)
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
<h3 id="CronJobRequestsSpec">CronJobRequestsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CronJobResourceSpec">CronJobResourceSpec</a>)
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
<h3 id="CronJobResourceSpec">CronJobResourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#CronJobSourceSpec">CronJobSourceSpec</a>)
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
<a href="#CronJobRequestsSpec">
CronJobRequestsSpec
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
<a href="#CronJobLimitsSpec">
CronJobLimitsSpec
</a>
</em>
</td>
<td>
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#CronJobResourceSpec">
CronJobResourceSpec
</a>
</em>
</td>
<td>
<p>Resource limits and Request specifications of the Receive Adapter Deployment</p>
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
<a href="https://godoc.org/github.com/knative/pkg/apis/duck/v1beta1#Status">
github.com/knative/pkg/apis/duck/v1beta1.Status
</a>
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
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>ab260095</code>.
</em></p>
