<p>Packages:</p>
<ul>
<li>
<a href="#sources.knative.dev%2fv1beta1">sources.knative.dev/v1beta1</a>
</li>
<li>
<a href="#messaging.knative.dev%2fv1alpha1">messaging.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#messaging.knative.dev%2fv1beta1">messaging.knative.dev/v1beta1</a>
</li>
<li>
<a href="#bindings.knative.dev%2fv1alpha1">bindings.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#bindings.knative.dev%2fv1beta1">bindings.knative.dev/v1beta1</a>
</li>
<li>
<a href="#sources.knative.dev%2fv1alpha1">sources.knative.dev/v1alpha1</a>
</li>
</ul>
<h2 id="sources.knative.dev/v1beta1">sources.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 contains API Schema definitions for the sources v1beta1 API group</p>
</p>
Resource Types:
<ul></ul>
<h3 id="sources.knative.dev/v1beta1.KafkaLimitsSpec">KafkaLimitsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1beta1.KafkaResourceSpec">KafkaResourceSpec</a>)
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
<h3 id="sources.knative.dev/v1beta1.KafkaRequestsSpec">KafkaRequestsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1beta1.KafkaResourceSpec">KafkaResourceSpec</a>)
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
<h3 id="sources.knative.dev/v1beta1.KafkaResourceSpec">KafkaResourceSpec
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
<code>requests</code></br>
<em>
<a href="#sources.knative.dev/v1beta1.KafkaRequestsSpec">
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
<a href="#sources.knative.dev/v1beta1.KafkaLimitsSpec">
KafkaLimitsSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1beta1.KafkaSource">KafkaSource
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
<a href="#sources.knative.dev/v1beta1.KafkaSourceSpec">
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
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1beta1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
[]string
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
<em>(Optional)</em>
<p>ConsumerGroupID is the consumer group ID.</p>
</td>
</tr>
<tr>
<td>
<code>SourceSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceSpec
</em>
</td>
<td>
<p>
(Members of <code>SourceSpec</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceSpec, which currently provides:
* Sink - a reference to an object that will resolve to a domain name or
a URI directly to use as the sink.
* CloudEventOverrides - defines overrides to control the output format
and modifications of the event sent to the sink.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1beta1.KafkaSourceStatus">
KafkaSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1beta1.KafkaSourceSpec">KafkaSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1beta1.KafkaSource">KafkaSource</a>)
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
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1beta1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
[]string
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
<em>(Optional)</em>
<p>ConsumerGroupID is the consumer group ID.</p>
</td>
</tr>
<tr>
<td>
<code>SourceSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceSpec
</em>
</td>
<td>
<p>
(Members of <code>SourceSpec</code> are embedded into this type.)
</p>
<p>inherits duck/v1 SourceSpec, which currently provides:
* Sink - a reference to an object that will resolve to a domain name or
a URI directly to use as the sink.
* CloudEventOverrides - defines overrides to control the output format
and modifications of the event sent to the sink.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1beta1.KafkaSourceStatus">KafkaSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1beta1.KafkaSource">KafkaSource</a>)
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
<hr/>
<h2 id="messaging.knative.dev/v1alpha1">messaging.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#messaging.knative.dev/v1alpha1.KafkaChannel">KafkaChannel</a>
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
knative.dev/pkg/apis/duck/v1.Status
</em>
</td>
<td>
<p>
(Members of <code>Status</code> are embedded into this type.)
</p>
<p>inherits duck/v1 Status, which currently provides:
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
<hr/>
<h2 id="messaging.knative.dev/v1beta1">messaging.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 is the v1beta1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#messaging.knative.dev/v1beta1.KafkaChannel">KafkaChannel</a>
</li></ul>
<h3 id="messaging.knative.dev/v1beta1.KafkaChannel">KafkaChannel
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
messaging.knative.dev/v1beta1
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
<a href="#messaging.knative.dev/v1beta1.KafkaChannelSpec">
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
<code>ChannelableSpec</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1.ChannelableSpec
</em>
</td>
<td>
<p>
(Members of <code>ChannelableSpec</code> are embedded into this type.)
</p>
<p>Channel conforms to Duck type Channelable.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.KafkaChannelStatus">
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
<h3 id="messaging.knative.dev/v1beta1.KafkaChannelSpec">KafkaChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.KafkaChannel">KafkaChannel</a>)
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
<code>ChannelableSpec</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1.ChannelableSpec
</em>
</td>
<td>
<p>
(Members of <code>ChannelableSpec</code> are embedded into this type.)
</p>
<p>Channel conforms to Duck type Channelable.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1beta1.KafkaChannelStatus">KafkaChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.KafkaChannel">KafkaChannel</a>)
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
<code>ChannelableStatus</code></br>
<em>
knative.dev/eventing/pkg/apis/duck/v1.ChannelableStatus
</em>
</td>
<td>
<p>
(Members of <code>ChannelableStatus</code> are embedded into this type.)
</p>
<p>Channel conforms to Duck type Channelable.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="bindings.knative.dev/v1alpha1">bindings.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 contains API Schema definitions for the sources v1alpha1 API group</p>
</p>
Resource Types:
<ul></ul>
<h3 id="bindings.knative.dev/v1alpha1.KafkaAuthSpec">KafkaAuthSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaBindingSpec">KafkaBindingSpec</a>, 
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
<code>bootstrapServers</code></br>
<em>
[]string
</em>
</td>
<td>
<p>Bootstrap servers are the Kafka servers the consumer will connect to.</p>
</td>
</tr>
<tr>
<td>
<code>net</code></br>
<em>
<a href="#bindings.knative.dev/v1alpha1.KafkaNetSpec">
KafkaNetSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1alpha1.KafkaBinding">KafkaBinding
</h3>
<p>
<p>KafkaBinding is the Schema for the kafkasources API.</p>
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
<a href="#bindings.knative.dev/v1alpha1.KafkaBindingSpec">
KafkaBindingSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>BindingSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.BindingSpec
</em>
</td>
<td>
<p>
(Members of <code>BindingSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1alpha1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
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
<a href="#bindings.knative.dev/v1alpha1.KafkaBindingStatus">
KafkaBindingStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1alpha1.KafkaBindingSpec">KafkaBindingSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaBinding">KafkaBinding</a>)
</p>
<p>
<p>KafkaBindingSpec defines the desired state of the KafkaBinding.</p>
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
<code>BindingSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.BindingSpec
</em>
</td>
<td>
<p>
(Members of <code>BindingSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1alpha1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1alpha1.KafkaBindingStatus">KafkaBindingStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaBinding">KafkaBinding</a>)
</p>
<p>
<p>KafkaBindingStatus defines the observed state of KafkaBinding.</p>
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
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1alpha1.KafkaNetSpec">KafkaNetSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaAuthSpec">KafkaAuthSpec</a>)
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
<a href="#bindings.knative.dev/v1alpha1.KafkaSASLSpec">
KafkaSASLSpec
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
<a href="#bindings.knative.dev/v1alpha1.KafkaTLSSpec">
KafkaTLSSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1alpha1.KafkaSASLSpec">KafkaSASLSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaNetSpec">KafkaNetSpec</a>)
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
<a href="#bindings.knative.dev/v1alpha1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1alpha1.SecretValueFromSource">
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
<h3 id="bindings.knative.dev/v1alpha1.KafkaTLSSpec">KafkaTLSSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaNetSpec">KafkaNetSpec</a>)
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
<a href="#bindings.knative.dev/v1alpha1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1alpha1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1alpha1.SecretValueFromSource">
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
<h3 id="bindings.knative.dev/v1alpha1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1alpha1.KafkaSASLSpec">KafkaSASLSpec</a>, 
<a href="#bindings.knative.dev/v1alpha1.KafkaTLSSpec">KafkaTLSSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#secretkeyselector-v1-core">
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
<h2 id="bindings.knative.dev/v1beta1">bindings.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 contains API Schema definitions for the sources v1beta1 API group</p>
</p>
Resource Types:
<ul></ul>
<h3 id="bindings.knative.dev/v1beta1.KafkaAuthSpec">KafkaAuthSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaBindingSpec">KafkaBindingSpec</a>, 
<a href="#sources.knative.dev/v1beta1.KafkaSourceSpec">KafkaSourceSpec</a>)
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
<code>bootstrapServers</code></br>
<em>
[]string
</em>
</td>
<td>
<p>Bootstrap servers are the Kafka servers the consumer will connect to.</p>
</td>
</tr>
<tr>
<td>
<code>net</code></br>
<em>
<a href="#bindings.knative.dev/v1beta1.KafkaNetSpec">
KafkaNetSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1beta1.KafkaBinding">KafkaBinding
</h3>
<p>
<p>KafkaBinding is the Schema for the kafkasources API.</p>
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
<a href="#bindings.knative.dev/v1beta1.KafkaBindingSpec">
KafkaBindingSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
<tr>
<td>
<code>BindingSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.BindingSpec
</em>
</td>
<td>
<p>
(Members of <code>BindingSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1beta1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
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
<a href="#bindings.knative.dev/v1beta1.KafkaBindingStatus">
KafkaBindingStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1beta1.KafkaBindingSpec">KafkaBindingSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaBinding">KafkaBinding</a>)
</p>
<p>
<p>KafkaBindingSpec defines the desired state of the KafkaBinding.</p>
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
<code>BindingSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.BindingSpec
</em>
</td>
<td>
<p>
(Members of <code>BindingSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1beta1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1beta1.KafkaBindingStatus">KafkaBindingStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaBinding">KafkaBinding</a>)
</p>
<p>
<p>KafkaBindingStatus defines the observed state of KafkaBinding.</p>
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
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1beta1.KafkaNetSpec">KafkaNetSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaAuthSpec">KafkaAuthSpec</a>)
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
<a href="#bindings.knative.dev/v1beta1.KafkaSASLSpec">
KafkaSASLSpec
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
<a href="#bindings.knative.dev/v1beta1.KafkaTLSSpec">
KafkaTLSSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="bindings.knative.dev/v1beta1.KafkaSASLSpec">KafkaSASLSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaNetSpec">KafkaNetSpec</a>)
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
<a href="#bindings.knative.dev/v1beta1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1beta1.SecretValueFromSource">
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
<h3 id="bindings.knative.dev/v1beta1.KafkaTLSSpec">KafkaTLSSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaNetSpec">KafkaNetSpec</a>)
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
<a href="#bindings.knative.dev/v1beta1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1beta1.SecretValueFromSource">
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
<a href="#bindings.knative.dev/v1beta1.SecretValueFromSource">
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
<h3 id="bindings.knative.dev/v1beta1.SecretValueFromSource">SecretValueFromSource
</h3>
<p>
(<em>Appears on:</em>
<a href="#bindings.knative.dev/v1beta1.KafkaSASLSpec">KafkaSASLSpec</a>, 
<a href="#bindings.knative.dev/v1beta1.KafkaTLSSpec">KafkaTLSSpec</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#secretkeyselector-v1-core">
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
<h2 id="sources.knative.dev/v1alpha1">sources.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 contains API Schema definitions for the sources v1alpha1 API group</p>
</p>
Resource Types:
<ul></ul>
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#objectmeta-v1-meta">
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
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1alpha1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
[]string
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
<em>(Optional)</em>
<p>ConsumerGroupID is the consumer group ID.</p>
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
Adapter Deployment.
Deprecated: v1beta1 drops this field.</p>
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
<p>Resource limits and Request specifications of the Receive Adapter Deployment
Deprecated: v1beta1 drops this field.</p>
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
<code>KafkaAuthSpec</code></br>
<em>
<a href="#bindings.knative.dev/v1alpha1.KafkaAuthSpec">
KafkaAuthSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>KafkaAuthSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>topics</code></br>
<em>
[]string
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
<em>(Optional)</em>
<p>ConsumerGroupID is the consumer group ID.</p>
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
Adapter Deployment.
Deprecated: v1beta1 drops this field.</p>
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
<p>Resource limits and Request specifications of the Receive Adapter Deployment
Deprecated: v1beta1 drops this field.</p>
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
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>ef8b78ed</code>.
</em></p>
