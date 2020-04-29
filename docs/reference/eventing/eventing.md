<p>Packages:</p>
<ul>
<li>
<a href="#flows.knative.dev%2fv1alpha1">flows.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#flows.knative.dev%2fv1beta1">flows.knative.dev/v1beta1</a>
</li>
<li>
<a href="#messaging.knative.dev%2fv1alpha1">messaging.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#sources.knative.dev%2fv1alpha1">sources.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#sources.knative.dev%2fv1alpha2">sources.knative.dev/v1alpha2</a>
</li>
<li>
<a href="#duck.knative.dev%2fv1alpha1">duck.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#duck.knative.dev%2fv1beta1">duck.knative.dev/v1beta1</a>
</li>
<li>
<a href="#eventing.knative.dev%2fv1alpha1">eventing.knative.dev/v1alpha1</a>
</li>
<li>
<a href="#eventing.knative.dev%2fv1beta1">eventing.knative.dev/v1beta1</a>
</li>
<li>
<a href="#messaging.knative.dev%2fv1beta1">messaging.knative.dev/v1beta1</a>
</li>
<li>
<a href="#configs.internal.knative.dev%2fv1alpha1">configs.internal.knative.dev/v1alpha1</a>
</li>
</ul>
<h2 id="flows.knative.dev/v1alpha1">flows.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul></ul>
<h3 id="flows.knative.dev/v1alpha1.Parallel">Parallel
</h3>
<p>
<p>Parallel defines conditional branches that will be wired in
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
<a href="#flows.knative.dev/v1alpha1.ParallelSpec">
ParallelSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Parallel.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>branches</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelBranch">
[]ParallelBranch
</a>
</em>
</td>
<td>
<p>Branches is the list of Filter/Subscribers pairs.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of a case Subscriber gets sent to
when the case does not have a Reply</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelStatus">
ParallelStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Parallel. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelBranch">ParallelBranch
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.ParallelSpec">ParallelSpec</a>)
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
<code>filter</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Filter is the expression guarding the branch</p>
</td>
</tr>
<tr>
<td>
<code>subscriber</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Subscriber receiving the event when the filter passes</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of Subscriber of this case gets sent to.
If not specified, sent the result to the Parallel Reply</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelBranchStatus">ParallelBranchStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.ParallelStatus">ParallelStatus</a>)
</p>
<p>
<p>ParallelBranchStatus represents the current state of a Parallel branch</p>
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
<code>filterSubscriptionStatus</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelSubscriptionStatus">
ParallelSubscriptionStatus
</a>
</em>
</td>
<td>
<p>FilterSubscriptionStatus corresponds to the filter subscription status.</p>
</td>
</tr>
<tr>
<td>
<code>filterChannelStatus</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelChannelStatus">
ParallelChannelStatus
</a>
</em>
</td>
<td>
<p>FilterChannelStatus corresponds to the filter channel status.</p>
</td>
</tr>
<tr>
<td>
<code>subscriberSubscriptionStatus</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelSubscriptionStatus">
ParallelSubscriptionStatus
</a>
</em>
</td>
<td>
<p>SubscriptionStatus corresponds to the subscriber subscription status.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelChannelStatus">ParallelChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.ParallelBranchStatus">ParallelBranchStatus</a>, 
<a href="#flows.knative.dev/v1alpha1.ParallelStatus">ParallelStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Channel is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelSpec">ParallelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.Parallel">Parallel</a>)
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
<code>branches</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelBranch">
[]ParallelBranch
</a>
</em>
</td>
<td>
<p>Branches is the list of Filter/Subscribers pairs.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of a case Subscriber gets sent to
when the case does not have a Reply</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelStatus">ParallelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.Parallel">Parallel</a>)
</p>
<p>
<p>ParallelStatus represents the current state of a Parallel.</p>
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
<code>ingressChannelStatus</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelChannelStatus">
ParallelChannelStatus
</a>
</em>
</td>
<td>
<p>IngressChannelStatus corresponds to the ingress channel status.</p>
</td>
</tr>
<tr>
<td>
<code>branchStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.ParallelBranchStatus">
[]ParallelBranchStatus
</a>
</em>
</td>
<td>
<p>BranchStatuses is an array of corresponding to branch statuses.
Matches the Spec.Branches array in the order.</p>
</td>
</tr>
<tr>
<td>
<code>AddressStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.AddressStatus
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>AddressStatus is the starting point to this Parallel. Sending to this
will target the first subscriber.
It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.ParallelSubscriptionStatus">ParallelSubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.ParallelBranchStatus">ParallelBranchStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Subscription is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.Sequence">Sequence
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
<a href="#flows.knative.dev/v1alpha1.SequenceSpec">
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
<a href="#flows.knative.dev/v1alpha1.SequenceStep">
[]SequenceStep
</a>
</em>
</td>
<td>
<p>Steps is the list of Destinations (processors / functions) that will be called in the order
provided.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.SequenceStatus">
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
<h3 id="flows.knative.dev/v1alpha1.SequenceChannelStatus">SequenceChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.SequenceStatus">SequenceStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Channel is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.SequenceSpec">SequenceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.Sequence">Sequence</a>)
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
<a href="#flows.knative.dev/v1alpha1.SequenceStep">
[]SequenceStep
</a>
</em>
</td>
<td>
<p>Steps is the list of Destinations (processors / functions) that will be called in the order
provided.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.SequenceStatus">SequenceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.Sequence">Sequence</a>)
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
<code>subscriptionStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.SequenceSubscriptionStatus">
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
<code>channelStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1alpha1.SequenceChannelStatus">
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
knative.dev/pkg/apis/duck/v1.AddressStatus
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
<h3 id="flows.knative.dev/v1alpha1.SequenceStep">SequenceStep
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.SequenceSpec">SequenceSpec</a>)
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
<code>Destination</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>
(Members of <code>Destination</code> are embedded into this type.)
</p>
<p>Subscriber receiving the step event</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification for events to the subscriber
This includes things like retries, DLQ, etc.
Needed for Roundtripping v1alpha1 &lt;-&gt; v1beta1.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1alpha1.SequenceSubscriptionStatus">SequenceSubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1alpha1.SequenceStatus">SequenceStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Subscription is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="flows.knative.dev/v1beta1">flows.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 is the v1beta1 version of the API.</p>
</p>
Resource Types:
<ul></ul>
<h3 id="flows.knative.dev/v1beta1.Parallel">Parallel
</h3>
<p>
<p>Parallel defines conditional branches that will be wired in
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
<a href="#flows.knative.dev/v1beta1.ParallelSpec">
ParallelSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the Parallel.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>branches</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelBranch">
[]ParallelBranch
</a>
</em>
</td>
<td>
<p>Branches is the list of Filter/Subscribers pairs.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of a case Subscriber gets sent to
when the case does not have a Reply</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelStatus">
ParallelStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the Parallel. This data may be out of
date.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelBranch">ParallelBranch
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.ParallelSpec">ParallelSpec</a>)
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
<code>filter</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Filter is the expression guarding the branch</p>
</td>
</tr>
<tr>
<td>
<code>subscriber</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Subscriber receiving the event when the filter passes</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of Subscriber of this case gets sent to.
If not specified, sent the result to the Parallel Reply</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelBranchStatus">ParallelBranchStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.ParallelStatus">ParallelStatus</a>)
</p>
<p>
<p>ParallelBranchStatus represents the current state of a Parallel branch</p>
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
<code>filterSubscriptionStatus</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelSubscriptionStatus">
ParallelSubscriptionStatus
</a>
</em>
</td>
<td>
<p>FilterSubscriptionStatus corresponds to the filter subscription status.</p>
</td>
</tr>
<tr>
<td>
<code>filterChannelStatus</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelChannelStatus">
ParallelChannelStatus
</a>
</em>
</td>
<td>
<p>FilterChannelStatus corresponds to the filter channel status.</p>
</td>
</tr>
<tr>
<td>
<code>subscriberSubscriptionStatus</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelSubscriptionStatus">
ParallelSubscriptionStatus
</a>
</em>
</td>
<td>
<p>SubscriptionStatus corresponds to the subscriber subscription status.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelChannelStatus">ParallelChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.ParallelBranchStatus">ParallelBranchStatus</a>, 
<a href="#flows.knative.dev/v1beta1.ParallelStatus">ParallelStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Channel is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelSpec">ParallelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.Parallel">Parallel</a>)
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
<code>branches</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelBranch">
[]ParallelBranch
</a>
</em>
</td>
<td>
<p>Branches is the list of Filter/Subscribers pairs.</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of a case Subscriber gets sent to
when the case does not have a Reply</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelStatus">ParallelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.Parallel">Parallel</a>)
</p>
<p>
<p>ParallelStatus represents the current state of a Parallel.</p>
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
<code>ingressChannelStatus</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelChannelStatus">
ParallelChannelStatus
</a>
</em>
</td>
<td>
<p>IngressChannelStatus corresponds to the ingress channel status.</p>
</td>
</tr>
<tr>
<td>
<code>branchStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.ParallelBranchStatus">
[]ParallelBranchStatus
</a>
</em>
</td>
<td>
<p>BranchStatuses is an array of corresponding to branch statuses.
Matches the Spec.Branches array in the order.</p>
</td>
</tr>
<tr>
<td>
<code>AddressStatus</code></br>
<em>
knative.dev/pkg/apis/duck/v1.AddressStatus
</em>
</td>
<td>
<p>
(Members of <code>AddressStatus</code> are embedded into this type.)
</p>
<p>AddressStatus is the starting point to this Parallel. Sending to this
will target the first subscriber.
It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.ParallelSubscriptionStatus">ParallelSubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.ParallelBranchStatus">ParallelBranchStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Subscription is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.Sequence">Sequence
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
<a href="#flows.knative.dev/v1beta1.SequenceSpec">
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
<a href="#flows.knative.dev/v1beta1.SequenceStep">
[]SequenceStep
</a>
</em>
</td>
<td>
<p>Steps is the list of Destinations (processors / functions) that will be called in the order
provided. Each step has its own delivery options</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.SequenceStatus">
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
<h3 id="flows.knative.dev/v1beta1.SequenceChannelStatus">SequenceChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.SequenceStatus">SequenceStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Channel is ready or not.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.SequenceSpec">SequenceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.Sequence">Sequence</a>)
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
<a href="#flows.knative.dev/v1beta1.SequenceStep">
[]SequenceStep
</a>
</em>
</td>
<td>
<p>Steps is the list of Destinations (processors / functions) that will be called in the order
provided. Each step has its own delivery options</p>
</td>
</tr>
<tr>
<td>
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use. If left unspecified, it is set to the default Channel CRD
for the namespace (or cluster, in case there are no defaults for the namespace).</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply is a Reference to where the result of the last Subscriber gets sent to.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.SequenceStatus">SequenceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.Sequence">Sequence</a>)
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
<code>subscriptionStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.SequenceSubscriptionStatus">
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
<code>channelStatuses</code></br>
<em>
<a href="#flows.knative.dev/v1beta1.SequenceChannelStatus">
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
knative.dev/pkg/apis/duck/v1.AddressStatus
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
<h3 id="flows.knative.dev/v1beta1.SequenceStep">SequenceStep
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.SequenceSpec">SequenceSpec</a>)
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
<code>Destination</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>
(Members of <code>Destination</code> are embedded into this type.)
</p>
<p>Subscriber receiving the step event</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification for events to the subscriber
This includes things like retries, DLQ, etc.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="flows.knative.dev/v1beta1.SequenceSubscriptionStatus">SequenceSubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#flows.knative.dev/v1beta1.SequenceStatus">SequenceStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis.Condition
</em>
</td>
<td>
<p>ReadyCondition indicates whether the Subscription is ready or not.</p>
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
<a href="#messaging.knative.dev/v1alpha1.Channel">Channel</a>
</li><li>
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannel">InMemoryChannel</a>
</li><li>
<a href="#messaging.knative.dev/v1alpha1.Subscription">Subscription</a>
</li></ul>
<h3 id="messaging.knative.dev/v1alpha1.Channel">Channel
</h3>
<p>
<p>Channel represents a generic Channel. It is normally used when we want a Channel, but don&rsquo;t need a specific Channel implementation.</p>
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
<td><code>Channel</code></td>
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
<a href="#messaging.knative.dev/v1alpha1.ChannelSpec">
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
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create the CRD Channel backing this Channel.
This is immutable after creation. Normally this is set by the Channel defaulter, not directly by the user.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<p>Delivery options.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.ChannelStatus">
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
<h3 id="messaging.knative.dev/v1alpha1.InMemoryChannel">InMemoryChannel
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
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannelSpec">
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
<a href="#duck.knative.dev/v1alpha1.Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<p>For round tripping (v1beta1 &lt;-&gt; v1alpha1&gt;</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannelStatus">
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
<h3 id="messaging.knative.dev/v1alpha1.Subscription">Subscription
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
messaging.knative.dev/v1alpha1
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
<a href="#messaging.knative.dev/v1alpha1.SubscriptionSpec">
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a Destination as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery configuration</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.SubscriptionStatus">
SubscriptionStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.ChannelSpec">ChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.Channel">Channel</a>)
</p>
<p>
<p>ChannelSpec defines which subscribers have expressed interest in receiving events from this Channel.
It also defines the ChannelTemplate to use in order to create the CRD Channel backing this Channel.</p>
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
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create the CRD Channel backing this Channel.
This is immutable after creation. Normally this is set by the Channel defaulter, not directly by the user.</p>
</td>
</tr>
<tr>
<td>
<code>subscribable</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<p>Delivery options.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.ChannelStatus">ChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.Channel">Channel</a>)
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
<p>Channel is Addressable. It currently exposes the endpoint as a
fully-qualified DNS name which will distribute traffic over the
provided targets from inside the cluster.</p>
<p>It generally has the form {channel}.{namespace}.svc.{cluster domain name}</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">
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
<tr>
<td>
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Channel is an ObjectReference to the Channel CRD backing this Channel.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.InMemoryChannelSpec">InMemoryChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannel">InMemoryChannel</a>)
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
<a href="#duck.knative.dev/v1alpha1.Subscribable">
Subscribable
</a>
</em>
</td>
<td>
<p>Channel conforms to Duck type Subscribable.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<p>For round tripping (v1beta1 &lt;-&gt; v1alpha1&gt;</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.InMemoryChannelStatus">InMemoryChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannel">InMemoryChannel</a>)
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">
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
<h3 id="messaging.knative.dev/v1alpha1.SubscriptionSpec">SubscriptionSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.Subscription">Subscription</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a Destination as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery configuration</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1alpha1.SubscriptionStatus">SubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.Subscription">Subscription</a>)
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
<code>physicalSubscription</code></br>
<em>
<a href="#messaging.knative.dev/v1alpha1.SubscriptionStatusPhysicalSubscription">
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
<h3 id="messaging.knative.dev/v1alpha1.SubscriptionStatusPhysicalSubscription">SubscriptionStatusPhysicalSubscription
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.SubscriptionStatus">SubscriptionStatus</a>)
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
knative.dev/pkg/apis.URL
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
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>ReplyURI is the fully resolved URI for the spec.reply.</p>
</td>
</tr>
<tr>
<td>
<code>deadLetterSinkURI</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>ReplyURI is the fully resolved URI for the spec.delivery.deadLetterSink.</p>
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
<a href="#sources.knative.dev/v1alpha1.ApiServerSource">ApiServerSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.PingSource">PingSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha1.SinkBinding">SinkBinding</a>
</li></ul>
<h3 id="sources.knative.dev/v1alpha1.ApiServerSource">ApiServerSource
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
sources.knative.dev/v1alpha1
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
<a href="#sources.knative.dev/v1alpha1.ApiServerSourceSpec">
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
<a href="#sources.knative.dev/v1alpha1.ApiServerResource">
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
<tr>
<td>
<code>owner</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKind">
APIVersionKind
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ResourceOwner is an additional filter to only track resources that are
owned by a specific resource type. If ResourceOwner matches Resources[n]
then Resources[n] is allowed to pass the ResourceOwner filter.</p>
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
<a href="#sources.knative.dev/v1alpha1.ApiServerSourceStatus">
ApiServerSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.PingSource">PingSource
</h3>
<p>
<p>PingSource is the Schema for the PingSources API.</p>
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
<td><code>PingSource</code></td>
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
<a href="#sources.knative.dev/v1alpha1.PingSourceSpec">
PingSourceSpec
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Sink is a reference to an object that will resolve to a uri to use as the sink.</p>
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
<a href="#sources.knative.dev/v1alpha1.PingResourceSpec">
PingResourceSpec
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
<a href="#sources.knative.dev/v1alpha1.PingSourceStatus">
PingSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.SinkBinding">SinkBinding
</h3>
<p>
<p>SinkBinding describes a Binding that is also a Source.
The <code>sink</code> (from the Source duck) is resolved to a URL and
then projected into the <code>subject</code> by augmenting the runtime
contract of the referenced containers to have a <code>K_SINK</code>
environment variable holding the endpoint to which to send
cloud events.</p>
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
<td><code>SinkBinding</code></td>
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
<a href="#sources.knative.dev/v1alpha1.SinkBindingSpec">
SinkBindingSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
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
</td>
</tr>
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
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha1.SinkBindingStatus">
SinkBindingStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.ApiServerResource">ApiServerResource
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.ApiServerSourceSpec">ApiServerSourceSpec</a>)
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
More info: <a href="https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds">https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds</a></p>
</td>
</tr>
<tr>
<td>
<code>labelSelector</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#labelselector-v1-meta">
Kubernetes meta/v1.LabelSelector
</a>
</em>
</td>
<td>
<p>LabelSelector restricts this source to objects with the selected labels
More info: <a href="http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors">http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors</a></p>
</td>
</tr>
<tr>
<td>
<code>controllerSelector</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#ownerreference-v1-meta">
Kubernetes meta/v1.OwnerReference
</a>
</em>
</td>
<td>
<p>ControllerSelector restricts this source to objects with a controlling owner reference of the specified kind.
Only apiVersion and kind are used. Both are optional.
Deprecated: Per-resource owner refs will no longer be supported in
v1alpha2, please use Spec.Owner as a GKV.</p>
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
<p>If true, send an event referencing the object controlling the resource
Deprecated: Per-resource controller flag will no longer be supported in
v1alpha2, please use Spec.Owner as a GKV.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.ApiServerSourceSpec">ApiServerSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.ApiServerSource">ApiServerSource</a>)
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
<a href="#sources.knative.dev/v1alpha1.ApiServerResource">
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
<tr>
<td>
<code>owner</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKind">
APIVersionKind
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ResourceOwner is an additional filter to only track resources that are
owned by a specific resource type. If ResourceOwner matches Resources[n]
then Resources[n] is allowed to pass the ResourceOwner filter.</p>
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
<h3 id="sources.knative.dev/v1alpha1.ApiServerSourceStatus">ApiServerSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.ApiServerSource">ApiServerSource</a>)
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
<h3 id="sources.knative.dev/v1alpha1.PingLimitsSpec">PingLimitsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PingResourceSpec">PingResourceSpec</a>)
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
<h3 id="sources.knative.dev/v1alpha1.PingRequestsSpec">PingRequestsSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PingResourceSpec">PingResourceSpec</a>)
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
<h3 id="sources.knative.dev/v1alpha1.PingResourceSpec">PingResourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PingSourceSpec">PingSourceSpec</a>)
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
<a href="#sources.knative.dev/v1alpha1.PingRequestsSpec">
PingRequestsSpec
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
<a href="#sources.knative.dev/v1alpha1.PingLimitsSpec">
PingLimitsSpec
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.PingSourceSpec">PingSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PingSource">PingSource</a>)
</p>
<p>
<p>PingSourceSpec defines the desired state of the PingSource.</p>
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Sink is a reference to an object that will resolve to a uri to use as the sink.</p>
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
<a href="#sources.knative.dev/v1alpha1.PingResourceSpec">
PingResourceSpec
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
<h3 id="sources.knative.dev/v1alpha1.PingSourceStatus">PingSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.PingSource">PingSource</a>)
</p>
<p>
<p>PingSourceStatus defines the observed state of PingSource.</p>
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
<h3 id="sources.knative.dev/v1alpha1.SinkBindingSpec">SinkBindingSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.SinkBinding">SinkBinding</a>)
</p>
<p>
<p>SinkBindingSpec holds the desired state of the SinkBinding (from the client).</p>
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
<code>SourceSpec</code></br>
<em>
knative.dev/pkg/apis/duck/v1.SourceSpec
</em>
</td>
<td>
<p>
(Members of <code>SourceSpec</code> are embedded into this type.)
</p>
</td>
</tr>
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
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha1.SinkBindingStatus">SinkBindingStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha1.SinkBinding">SinkBinding</a>)
</p>
<p>
<p>SinkBindingStatus communicates the observed state of the SinkBinding (from the controller).</p>
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
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="sources.knative.dev/v1alpha2">sources.knative.dev/v1alpha2</h2>
<p>
<p>Package v1alpha2 contains API Schema definitions for the sources v1beta1 API group</p>
</p>
Resource Types:
<ul><li>
<a href="#sources.knative.dev/v1alpha2.ApiServerSource">ApiServerSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha2.ContainerSource">ContainerSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha2.PingSource">PingSource</a>
</li><li>
<a href="#sources.knative.dev/v1alpha2.SinkBinding">SinkBinding</a>
</li></ul>
<h3 id="sources.knative.dev/v1alpha2.ApiServerSource">ApiServerSource
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
sources.knative.dev/v1alpha2
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
<a href="#sources.knative.dev/v1alpha2.ApiServerSourceSpec">
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKindSelector">
[]APIVersionKindSelector
</a>
</em>
</td>
<td>
<p>Resource are the resources this source will track and send related
lifecycle events from the Kubernetes ApiServer, with an optional label
selector to help filter.</p>
</td>
</tr>
<tr>
<td>
<code>owner</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKind">
APIVersionKind
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ResourceOwner is an additional filter to only track resources that are
owned by a specific resource type. If ResourceOwner matches Resources[n]
then Resources[n] is allowed to pass the ResourceOwner filter.</p>
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
<em>(Optional)</em>
<p>EventMode controls the format of the event.
<code>Reference</code> sends a dataref event type for the resource under watch.
<code>Resource</code> send the full resource lifecycle event.
Defaults to <code>Reference</code></p>
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
source. Defaults to default if not set.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.ApiServerSourceStatus">
ApiServerSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.ContainerSource">ContainerSource
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
sources.knative.dev/v1alpha2
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
<a href="#sources.knative.dev/v1alpha2.ContainerSourceSpec">
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
<tr>
<td>
<code>template</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#podtemplatespec-v1-core">
Kubernetes core/v1.PodTemplateSpec
</a>
</em>
</td>
<td>
<p>Template describes the pods that will be created</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.ContainerSourceStatus">
ContainerSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.PingSource">PingSource
</h3>
<p>
<p>PingSource is the Schema for the PingSources API.</p>
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
sources.knative.dev/v1alpha2
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>PingSource</code></td>
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
<a href="#sources.knative.dev/v1alpha2.PingSourceSpec">
PingSourceSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
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
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Schedule is the cronjob schedule. Defaults to <code>* * * * *</code>.</p>
</td>
</tr>
<tr>
<td>
<code>jsonData</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>JsonData is json encoded data used as the body of the event posted to
the sink. Default is empty. If set, datacontenttype will also be set
to &ldquo;application/json&rdquo;.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.PingSourceStatus">
PingSourceStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.SinkBinding">SinkBinding
</h3>
<p>
<p>SinkBinding describes a Binding that is also a Source.
The <code>sink</code> (from the Source duck) is resolved to a URL and
then projected into the <code>subject</code> by augmenting the runtime
contract of the referenced containers to have a <code>K_SINK</code>
environment variable holding the endpoint to which to send
cloud events.</p>
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
sources.knative.dev/v1alpha2
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>SinkBinding</code></td>
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
<a href="#sources.knative.dev/v1alpha2.SinkBindingSpec">
SinkBindingSpec
</a>
</em>
</td>
<td>
<br/>
<br/>
<table>
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
<p>inherits duck/v1alpha1 BindingSpec, which currently provides:
* Subject - Subject references the resource(s) whose &ldquo;runtime contract&rdquo;
should be augmented by Binding implementations.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.SinkBindingStatus">
SinkBindingStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.APIVersionKind">APIVersionKind
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ApiServerSourceSpec">ApiServerSourceSpec</a>, 
<a href="#sources.knative.dev/v1alpha1.ApiServerSourceSpec">ApiServerSourceSpec</a>)
</p>
<p>
<p>APIVersionKind is an APIVersion and Kind tuple.</p>
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
<p>APIVersion - the API version of the resource to watch.</p>
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
More info: <a href="https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds">https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.APIVersionKindSelector">APIVersionKindSelector
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ApiServerSourceSpec">ApiServerSourceSpec</a>)
</p>
<p>
<p>APIVersionKindSelector is an APIVersion Kind tuple with a LabelSelector.</p>
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
<p>APIVersion - the API version of the resource to watch.</p>
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
More info: <a href="https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds">https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds</a></p>
</td>
</tr>
<tr>
<td>
<code>selector</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#labelselector-v1-meta">
Kubernetes meta/v1.LabelSelector
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>LabelSelector filters this source to objects to those resources pass the
label selector.
More info: <a href="http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors">http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.ApiServerSourceSpec">ApiServerSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ApiServerSource">ApiServerSource</a>)
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
<tr>
<td>
<code>resources</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKindSelector">
[]APIVersionKindSelector
</a>
</em>
</td>
<td>
<p>Resource are the resources this source will track and send related
lifecycle events from the Kubernetes ApiServer, with an optional label
selector to help filter.</p>
</td>
</tr>
<tr>
<td>
<code>owner</code></br>
<em>
<a href="#sources.knative.dev/v1alpha2.APIVersionKind">
APIVersionKind
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ResourceOwner is an additional filter to only track resources that are
owned by a specific resource type. If ResourceOwner matches Resources[n]
then Resources[n] is allowed to pass the ResourceOwner filter.</p>
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
<em>(Optional)</em>
<p>EventMode controls the format of the event.
<code>Reference</code> sends a dataref event type for the resource under watch.
<code>Resource</code> send the full resource lifecycle event.
Defaults to <code>Reference</code></p>
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
source. Defaults to default if not set.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.ApiServerSourceStatus">ApiServerSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ApiServerSource">ApiServerSource</a>)
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
<h3 id="sources.knative.dev/v1alpha2.ContainerSourceSpec">ContainerSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ContainerSource">ContainerSource</a>)
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
<tr>
<td>
<code>template</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#podtemplatespec-v1-core">
Kubernetes core/v1.PodTemplateSpec
</a>
</em>
</td>
<td>
<p>Template describes the pods that will be created</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.ContainerSourceStatus">ContainerSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.ContainerSource">ContainerSource</a>)
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
<h3 id="sources.knative.dev/v1alpha2.PingSourceSpec">PingSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.PingSource">PingSource</a>)
</p>
<p>
<p>PingSourceSpec defines the desired state of the PingSource.</p>
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
<tr>
<td>
<code>schedule</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Schedule is the cronjob schedule. Defaults to <code>* * * * *</code>.</p>
</td>
</tr>
<tr>
<td>
<code>jsonData</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>JsonData is json encoded data used as the body of the event posted to
the sink. Default is empty. If set, datacontenttype will also be set
to &ldquo;application/json&rdquo;.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.PingSourceStatus">PingSourceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.PingSource">PingSource</a>)
</p>
<p>
<p>PingSourceStatus defines the observed state of PingSource.</p>
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
<h3 id="sources.knative.dev/v1alpha2.SinkBindingSpec">SinkBindingSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.SinkBinding">SinkBinding</a>)
</p>
<p>
<p>SinkBindingSpec holds the desired state of the SinkBinding (from the client).</p>
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
<p>inherits duck/v1alpha1 BindingSpec, which currently provides:
* Subject - Subject references the resource(s) whose &ldquo;runtime contract&rdquo;
should be augmented by Binding implementations.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="sources.knative.dev/v1alpha2.SinkBindingStatus">SinkBindingStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#sources.knative.dev/v1alpha2.SinkBinding">SinkBinding</a>)
</p>
<p>
<p>SinkBindingStatus communicates the observed state of the SinkBinding (from the controller).</p>
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
<h2 id="duck.knative.dev/v1alpha1">duck.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul></ul>
<h3 id="duck.knative.dev/v1alpha1.Channelable">Channelable
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
<a href="#duck.knative.dev/v1alpha1.ChannelableSpec">
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">
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
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.ChannelableStatus">
ChannelableStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.ChannelableCombined">ChannelableCombined
</h3>
<p>
<p>ChannelableCombined is a skeleton type wrapping Subscribable and Addressable of both
v1alpha1 and v1beta1 duck types. This is not to be used by resource writers and is
only used by Subscription Controller to synthesize patches and read the Status
of the Channelable Resources.
This is not a real resource.</p>
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
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedSpec">
ChannelableCombinedSpec
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">
SubscribableTypeSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeSpec</code> are embedded into this type.)
</p>
<p>SubscribableTypeSpec is for the v1alpha1 spec compatibility.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">
SubscribableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableSpec</code> are embedded into this type.)
</p>
<p>SubscribableSpec is for the v1beta1 spec compatibility.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedStatus">
ChannelableCombinedStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.ChannelableCombinedSpec">ChannelableCombinedSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombined">ChannelableCombined</a>)
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">
SubscribableTypeSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeSpec</code> are embedded into this type.)
</p>
<p>SubscribableTypeSpec is for the v1alpha1 spec compatibility.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">
SubscribableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableSpec</code> are embedded into this type.)
</p>
<p>SubscribableSpec is for the v1beta1 spec compatibility.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.ChannelableCombinedStatus">ChannelableCombinedStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombined">ChannelableCombined</a>)
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
<p>AddressStatus is the part where the Channelable fulfills the Addressable contract.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">
SubscribableTypeStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableTypeStatus</code> are embedded into this type.)
</p>
<p>SubscribableTypeStatus is the v1alpha1 part of the Subscribers status</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableStatus</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableStatus">
SubscribableStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableStatus</code> are embedded into this type.)
</p>
<p>SubscribableStatus is the v1beta1 part of the Subscribers status.</p>
</td>
</tr>
<tr>
<td>
<code>errorChannel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ErrorChannel is set by the channel when it supports native error handling via a channel</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.ChannelableSpec">ChannelableSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.Channelable">Channelable</a>)
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">
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
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.ChannelableStatus">ChannelableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.Channelable">Channelable</a>)
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
<p>AddressStatus is the part where the Channelable fulfills the Addressable contract.</p>
</td>
</tr>
<tr>
<td>
<code>SubscribableTypeStatus</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">
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
<tr>
<td>
<code>errorChannel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ErrorChannel is set by the channel when it supports native error handling via a channel</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.Resource">Resource
</h3>
<p>
<p>Resource is a skeleton type wrapping all Kubernetes resources. It is typically used to watch
arbitrary other resources (such as any Source or Addressable). This is not a real resource.</p>
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
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.Subscribable">Subscribable
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.ChannelSpec">ChannelSpec</a>, 
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannelSpec">InMemoryChannelSpec</a>, 
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">SubscribableTypeSpec</a>)
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
<a href="#duck.knative.dev/v1alpha1.SubscriberSpec">
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
<h3 id="duck.knative.dev/v1alpha1.SubscribableStatus">SubscribableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">SubscribableTypeStatus</a>)
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
<a href="#duck.knative.dev/v1alpha1.SubscriberStatus">
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
<h3 id="duck.knative.dev/v1alpha1.SubscribableType">SubscribableType
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeSpec">
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
<a href="#duck.knative.dev/v1alpha1.Subscribable">
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
<a href="#duck.knative.dev/v1alpha1.SubscribableTypeStatus">
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
<h3 id="duck.knative.dev/v1alpha1.SubscribableTypeSpec">SubscribableTypeSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedSpec">ChannelableCombinedSpec</a>, 
<a href="#duck.knative.dev/v1alpha1.ChannelableSpec">ChannelableSpec</a>, 
<a href="#duck.knative.dev/v1alpha1.SubscribableType">SubscribableType</a>)
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
<a href="#duck.knative.dev/v1alpha1.Subscribable">
Subscribable
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.SubscribableTypeStatus">SubscribableTypeStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1alpha1.ChannelStatus">ChannelStatus</a>, 
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedStatus">ChannelableCombinedStatus</a>, 
<a href="#duck.knative.dev/v1alpha1.ChannelableStatus">ChannelableStatus</a>, 
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannelStatus">InMemoryChannelStatus</a>, 
<a href="#duck.knative.dev/v1alpha1.SubscribableType">SubscribableType</a>)
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
<code>subscribableStatus</code></br>
<em>
<a href="#duck.knative.dev/v1alpha1.SubscribableStatus">
SubscribableStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.SubscriberSpec">SubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.Subscribable">Subscribable</a>)
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
knative.dev/pkg/apis.URL
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
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
<tr>
<td>
<code>deadLetterSink</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1alpha1.SubscriberStatus">SubscriberStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.SubscribableStatus">SubscribableStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#conditionstatus-v1-core">
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
<h2 id="duck.knative.dev/v1beta1">duck.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 is the v1beta1 version of the API.</p>
</p>
Resource Types:
<ul></ul>
<h3 id="duck.knative.dev/v1beta1.BackoffPolicyType">BackoffPolicyType
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">DeliverySpec</a>)
</p>
<p>
<p>BackoffPolicyType is the type for backoff policies</p>
</p>
<h3 id="duck.knative.dev/v1beta1.Channelable">Channelable
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
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">
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
<code>SubscribableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">
SubscribableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableStatus">
ChannelableStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.ChannelableSpec">ChannelableSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.ChannelSpec">ChannelSpec</a>, 
<a href="#duck.knative.dev/v1beta1.Channelable">Channelable</a>, 
<a href="#messaging.knative.dev/v1beta1.InMemoryChannelSpec">InMemoryChannelSpec</a>)
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
<code>SubscribableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">
SubscribableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.ChannelableStatus">ChannelableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.ChannelStatus">ChannelStatus</a>, 
<a href="#duck.knative.dev/v1beta1.Channelable">Channelable</a>, 
<a href="#messaging.knative.dev/v1beta1.InMemoryChannelStatus">InMemoryChannelStatus</a>)
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
knative.dev/pkg/apis/duck/v1.AddressStatus
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
<code>SubscribableStatus</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableStatus">
SubscribableStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>SubscribableStatus</code> are embedded into this type.)
</p>
<p>Subscribers is populated with the statuses of each of the Channelable&rsquo;s subscribers.</p>
</td>
</tr>
<tr>
<td>
<code>deadLetterChannel</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeadLetterChannel is a KReference and is set by the channel when it supports native error handling via a channel
Failed messages are delivered here.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.DeliverySpec">DeliverySpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.BrokerSpec">BrokerSpec</a>, 
<a href="#eventing.knative.dev/v1beta1.BrokerSpec">BrokerSpec</a>, 
<a href="#messaging.knative.dev/v1alpha1.ChannelSpec">ChannelSpec</a>, 
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedSpec">ChannelableCombinedSpec</a>, 
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">ChannelableSpec</a>, 
<a href="#duck.knative.dev/v1alpha1.ChannelableSpec">ChannelableSpec</a>, 
<a href="#messaging.knative.dev/v1alpha1.InMemoryChannelSpec">InMemoryChannelSpec</a>, 
<a href="#flows.knative.dev/v1alpha1.SequenceStep">SequenceStep</a>, 
<a href="#flows.knative.dev/v1beta1.SequenceStep">SequenceStep</a>, 
<a href="#duck.knative.dev/v1alpha1.SubscriberSpec">SubscriberSpec</a>, 
<a href="#duck.knative.dev/v1beta1.SubscriberSpec">SubscriberSpec</a>, 
<a href="#messaging.knative.dev/v1beta1.SubscriptionSpec">SubscriptionSpec</a>, 
<a href="#messaging.knative.dev/v1alpha1.SubscriptionSpec">SubscriptionSpec</a>)
</p>
<p>
<p>DeliverySpec contains the delivery options for event senders,
such as channelable and source.</p>
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
<code>deadLetterSink</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeadLetterSink is the sink receiving event that couldn&rsquo;t be sent to
a destination.</p>
</td>
</tr>
<tr>
<td>
<code>retry</code></br>
<em>
int32
</em>
</td>
<td>
<em>(Optional)</em>
<p>Retry is the minimum number of retries the sender should attempt when
sending an event before moving it to the dead letter sink.</p>
</td>
</tr>
<tr>
<td>
<code>backoffPolicy</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.BackoffPolicyType">
BackoffPolicyType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>BackoffPolicy is the retry backoff policy (linear, exponential)</p>
</td>
</tr>
<tr>
<td>
<code>backoffDelay</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>BackoffDelay is the delay before retrying.
More information on Duration format: <a href="https://www.ietf.org/rfc/rfc3339.txt">https://www.ietf.org/rfc/rfc3339.txt</a></p>
<p>For linear policy, backoff delay is the time interval between retries.
For exponential policy , backoff delay is backoffDelay*2^<numberOfRetries></p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.DeliveryStatus">DeliveryStatus
</h3>
<p>
<p>DeliveryStatus contains the Status of an object supporting delivery options.</p>
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
<code>deadLetterChannel</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeadLetterChannel is a KReference that is the reference to the native, platform specific channel
where failed events are sent to.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.Subscribable">Subscribable
</h3>
<p>
<p>Subscribable is a skeleton type wrapping Subscribable in the manner we expect resource writers
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
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">
SubscribableSpec
</a>
</em>
</td>
<td>
<p>SubscribableSpec is the part where Subscribable object is
configured as to be compatible with Subscribable contract.</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>subscribers</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscriberSpec">
[]SubscriberSpec
</a>
</em>
</td>
<td>
<p>This is the list of subscriptions for this subscribable.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.SubscribableStatus">
SubscribableStatus
</a>
</em>
</td>
<td>
<p>SubscribableStatus is the part where SubscribableStatus object is
configured as to be compatible with Subscribable contract.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.SubscribableSpec">SubscribableSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedSpec">ChannelableCombinedSpec</a>, 
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">ChannelableSpec</a>, 
<a href="#duck.knative.dev/v1beta1.Subscribable">Subscribable</a>)
</p>
<p>
<p>SubscribableSpec shows how we expect folks to embed Subscribable in their Spec field.</p>
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
<a href="#duck.knative.dev/v1beta1.SubscriberSpec">
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
<h3 id="duck.knative.dev/v1beta1.SubscribableStatus">SubscribableStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1alpha1.ChannelableCombinedStatus">ChannelableCombinedStatus</a>, 
<a href="#duck.knative.dev/v1beta1.ChannelableStatus">ChannelableStatus</a>, 
<a href="#duck.knative.dev/v1beta1.Subscribable">Subscribable</a>)
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
<a href="#duck.knative.dev/v1beta1.SubscriberStatus">
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
<h3 id="duck.knative.dev/v1beta1.SubscriberSpec">SubscriberSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1beta1.SubscribableSpec">SubscribableSpec</a>)
</p>
<p>
<p>SubscriberSpec defines a single subscriber to a Subscribable.</p>
<p>At least one of SubscriberURI and ReplyURI must be present</p>
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
<code>subscriberUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>SubscriberURI is the endpoint for the subscriber</p>
</td>
</tr>
<tr>
<td>
<code>replyUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>ReplyURI is the endpoint for the reply</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeliverySpec contains options controlling the event delivery</p>
</td>
</tr>
</tbody>
</table>
<h3 id="duck.knative.dev/v1beta1.SubscriberStatus">SubscriberStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#duck.knative.dev/v1beta1.SubscribableStatus">SubscribableStatus</a>)
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#conditionstatus-v1-core">
Kubernetes core/v1.ConditionStatus
</a>
</em>
</td>
<td>
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
<h2 id="eventing.knative.dev/v1alpha1">eventing.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#eventing.knative.dev/v1alpha1.Broker">Broker</a>
</li><li>
<a href="#eventing.knative.dev/v1alpha1.EventType">EventType</a>
</li><li>
<a href="#eventing.knative.dev/v1alpha1.Trigger">Trigger</a>
</li></ul>
<h3 id="eventing.knative.dev/v1alpha1.Broker">Broker
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
<a href="#eventing.knative.dev/v1alpha1.BrokerSpec">
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
<code>channelTemplateSpec</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use to create all the Channels used internally by the
Broker. If left unspecified, it is set to the default Channel CRD for the namespace (or cluster, in case there
are no defaults for the namespace).
Deprecated: See spec.config to configure aditional broker options.
Unless class is <TBD> for channel based broker implementation.</p>
</td>
</tr>
<tr>
<td>
<code>config</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>Config is a KReference to the configuration that specifies
configuration options for this Broker. For example, this could be
a pointer to a ConfigMap.
NOTE: this is for backwards compatibility with v1alpha1 &lt;-&gt; v1beta1 conversions.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification to be used internally by the broker to
create subscriptions.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#eventing.knative.dev/v1alpha1.BrokerStatus">
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
<h3 id="eventing.knative.dev/v1alpha1.EventType">EventType
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
<a href="#eventing.knative.dev/v1alpha1.EventTypeSpec">
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
<em>(Optional)</em>
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
<em>(Optional)</em>
<p>TODO remove <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a>
Broker refers to the Broker that can provide the EventType.</p>
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
<a href="#eventing.knative.dev/v1alpha1.EventTypeStatus">
EventTypeStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the EventType.
This data may be out of date.
TODO might be removed <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.Trigger">Trigger
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
<a href="#eventing.knative.dev/v1alpha1.TriggerSpec">
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
<a href="#eventing.knative.dev/v1alpha1.TriggerFilter">
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
knative.dev/pkg/apis/duck/v1.Destination
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
<a href="#eventing.knative.dev/v1alpha1.TriggerStatus">
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
<h3 id="eventing.knative.dev/v1alpha1.BrokerSpec">BrokerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.Broker">Broker</a>)
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
<code>channelTemplateSpec</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ChannelTemplate specifies which Channel CRD to use to create all the Channels used internally by the
Broker. If left unspecified, it is set to the default Channel CRD for the namespace (or cluster, in case there
are no defaults for the namespace).
Deprecated: See spec.config to configure aditional broker options.
Unless class is <TBD> for channel based broker implementation.</p>
</td>
</tr>
<tr>
<td>
<code>config</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>Config is a KReference to the configuration that specifies
configuration options for this Broker. For example, this could be
a pointer to a ConfigMap.
NOTE: this is for backwards compatibility with v1alpha1 &lt;-&gt; v1beta1 conversions.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification to be used internally by the broker to
create subscriptions.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.BrokerStatus">BrokerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.Broker">Broker</a>)
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
<code>address</code></br>
<em>
knative.dev/pkg/apis/duck/v1alpha1.Addressable
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
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>TriggerChannel is an objectref to the object for the TriggerChannel</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.EventTypeSpec">EventTypeSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.EventType">EventType</a>)
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
<em>(Optional)</em>
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
<em>(Optional)</em>
<p>TODO remove <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a>
Broker refers to the Broker that can provide the EventType.</p>
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
<h3 id="eventing.knative.dev/v1alpha1.EventTypeStatus">EventTypeStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.EventType">EventType</a>)
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
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.TriggerFilter">TriggerFilter
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.TriggerSpec">TriggerSpec</a>)
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
<a href="#eventing.knative.dev/v1alpha1.TriggerFilterSourceAndType">
TriggerFilterSourceAndType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedSourceAndType filters events based on exact matches on the
CloudEvents type and source attributes. This field has been replaced by the
Attributes field.</p>
</td>
</tr>
<tr>
<td>
<code>attributes</code></br>
<em>
<a href="#eventing.knative.dev/v1alpha1.TriggerFilterAttributes">
TriggerFilterAttributes
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Attributes filters events by exact match on event context attributes.
Each key in the map is compared with the equivalent key in the event
context. An event passes the filter if all values are equal to the
specified values.</p>
<p>Nested context attributes are not supported as keys. Only string values are supported.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.TriggerFilterAttributes">TriggerFilterAttributes
(<code>map[string]string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.TriggerFilter">TriggerFilter</a>)
</p>
<p>
<p>TriggerFilterAttributes is a map of context attribute names to values for
filtering by equality. Only exact matches will pass the filter. You can use the value &ldquo;
to indicate all strings match.</p>
</p>
<h3 id="eventing.knative.dev/v1alpha1.TriggerFilterSourceAndType">TriggerFilterSourceAndType
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.TriggerFilter">TriggerFilter</a>)
</p>
<p>
<p>TriggerFilterSourceAndType filters events based on exact matches on the cloud event&rsquo;s type and
source attributes. Only exact matches will pass the filter. Either or both type and source can
use the value &ldquo; to indicate all strings match.</p>
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
<h3 id="eventing.knative.dev/v1alpha1.TriggerSpec">TriggerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.Trigger">Trigger</a>)
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
<a href="#eventing.knative.dev/v1alpha1.TriggerFilter">
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Subscriber is the addressable that receives events from the Broker that pass the Filter. It
is required.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1alpha1.TriggerStatus">TriggerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.Trigger">Trigger</a>)
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
<code>subscriberURI</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>SubscriberURI is the resolved URI of the receiver for this Trigger.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="eventing.knative.dev/v1beta1">eventing.knative.dev/v1beta1</h2>
<p>
<p>Package v1beta1 is the v1beta1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#eventing.knative.dev/v1beta1.Broker">Broker</a>
</li><li>
<a href="#eventing.knative.dev/v1beta1.EventType">EventType</a>
</li><li>
<a href="#eventing.knative.dev/v1beta1.Trigger">Trigger</a>
</li></ul>
<h3 id="eventing.knative.dev/v1beta1.Broker">Broker
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
eventing.knative.dev/v1beta1
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
<a href="#eventing.knative.dev/v1beta1.BrokerSpec">
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
<code>config</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>Config is a KReference to the configuration that specifies
configuration options for this Broker. For example, this could be
a pointer to a ConfigMap.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification for Events within the Broker mesh.
This includes things like retries, DLQ, etc.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#eventing.knative.dev/v1beta1.BrokerStatus">
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
<h3 id="eventing.knative.dev/v1beta1.EventType">EventType
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
eventing.knative.dev/v1beta1
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
<a href="#eventing.knative.dev/v1beta1.EventTypeSpec">
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
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>Source is a URI, it represents the CloudEvents source.</p>
</td>
</tr>
<tr>
<td>
<code>schema</code></br>
<em>
knative.dev/pkg/apis.URL
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
<code>schemaData</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SchemaData allows the CloudEvents schema to be stored directly in the
EventType. Content is dependent on the encoding. Optional attribute.
The contents are not validated or manipulated by the system.</p>
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
<em>(Optional)</em>
<p>TODO remove <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a>
Broker refers to the Broker that can provide the EventType.</p>
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
<a href="#eventing.knative.dev/v1beta1.EventTypeStatus">
EventTypeStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status represents the current state of the EventType.
This data may be out of date.
TODO might be removed <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.Trigger">Trigger
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
eventing.knative.dev/v1beta1
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
<a href="#eventing.knative.dev/v1beta1.TriggerSpec">
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
<a href="#eventing.knative.dev/v1beta1.TriggerFilter">
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
knative.dev/pkg/apis/duck/v1.Destination
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
<a href="#eventing.knative.dev/v1beta1.TriggerStatus">
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
<h3 id="eventing.knative.dev/v1beta1.BrokerSpec">BrokerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.Broker">Broker</a>)
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
<code>config</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<em>(Optional)</em>
<p>Config is a KReference to the configuration that specifies
configuration options for this Broker. For example, this could be
a pointer to a ConfigMap.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery is the delivery specification for Events within the Broker mesh.
This includes things like retries, DLQ, etc.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.BrokerStatus">BrokerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.Broker">Broker</a>)
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
<code>address</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Addressable
</em>
</td>
<td>
<p>Broker is Addressable. It exposes the endpoint as an URI to get events
delivered into the Broker mesh.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.EventTypeSpec">EventTypeSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.EventType">EventType</a>)
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
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>Source is a URI, it represents the CloudEvents source.</p>
</td>
</tr>
<tr>
<td>
<code>schema</code></br>
<em>
knative.dev/pkg/apis.URL
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
<code>schemaData</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SchemaData allows the CloudEvents schema to be stored directly in the
EventType. Content is dependent on the encoding. Optional attribute.
The contents are not validated or manipulated by the system.</p>
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
<em>(Optional)</em>
<p>TODO remove <a href="https://github.com/knative/eventing/issues/2750">https://github.com/knative/eventing/issues/2750</a>
Broker refers to the Broker that can provide the EventType.</p>
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
<h3 id="eventing.knative.dev/v1beta1.EventTypeStatus">EventTypeStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.EventType">EventType</a>)
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
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.TriggerFilter">TriggerFilter
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.TriggerSpec">TriggerSpec</a>)
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
<code>attributes</code></br>
<em>
<a href="#eventing.knative.dev/v1beta1.TriggerFilterAttributes">
TriggerFilterAttributes
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Attributes filters events by exact match on event context attributes.
Each key in the map is compared with the equivalent key in the event
context. An event passes the filter if all values are equal to the
specified values.</p>
<p>Nested context attributes are not supported as keys. Only string values are supported.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.TriggerFilterAttributes">TriggerFilterAttributes
(<code>map[string]string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.TriggerFilter">TriggerFilter</a>)
</p>
<p>
<p>TriggerFilterAttributes is a map of context attribute names to values for
filtering by equality. Only exact matches will pass the filter. You can use the value &ldquo;
to indicate all strings match.</p>
</p>
<h3 id="eventing.knative.dev/v1beta1.TriggerSpec">TriggerSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.Trigger">Trigger</a>)
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
<a href="#eventing.knative.dev/v1beta1.TriggerFilter">
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<p>Subscriber is the addressable that receives events from the Broker that pass the Filter. It
is required.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="eventing.knative.dev/v1beta1.TriggerStatus">TriggerStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1beta1.Trigger">Trigger</a>)
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
<code>subscriberUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>SubscriberURI is the resolved URI of the receiver for this Trigger.</p>
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
<a href="#messaging.knative.dev/v1beta1.Channel">Channel</a>
</li><li>
<a href="#messaging.knative.dev/v1beta1.InMemoryChannel">InMemoryChannel</a>
</li><li>
<a href="#messaging.knative.dev/v1beta1.Subscription">Subscription</a>
</li></ul>
<h3 id="messaging.knative.dev/v1beta1.Channel">Channel
</h3>
<p>
<p>Channel represents a generic Channel. It is normally used when we want a Channel, but don&rsquo;t need a specific Channel implementation.</p>
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
<td><code>Channel</code></td>
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
<a href="#messaging.knative.dev/v1beta1.ChannelSpec">
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
<code>channelTemplate</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create the CRD Channel backing this Channel.
This is immutable after creation. Normally this is set by the Channel defaulter, not directly by the user.</p>
</td>
</tr>
<tr>
<td>
<code>ChannelableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">
ChannelableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ChannelableSpec</code> are embedded into this type.)
</p>
<p>Channel conforms to ChannelableSpec</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.ChannelStatus">
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
<h3 id="messaging.knative.dev/v1beta1.InMemoryChannel">InMemoryChannel
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
messaging.knative.dev/v1beta1
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
<a href="#messaging.knative.dev/v1beta1.InMemoryChannelSpec">
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
<code>ChannelableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">
ChannelableSpec
</a>
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
<a href="#messaging.knative.dev/v1beta1.InMemoryChannelStatus">
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
<h3 id="messaging.knative.dev/v1beta1.Subscription">Subscription
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
messaging.knative.dev/v1beta1
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
<a href="#messaging.knative.dev/v1beta1.SubscriptionSpec">
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
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Reference to a channel that will be used to create the subscription
You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
The resource pointed by this ObjectReference must meet the
contract to the ChannelableSpec duck type. If the resource does not
meet this contract it will be reflected in the Subscription&rsquo;s status.</p>
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a Destination as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery configuration</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.SubscriptionStatus">
SubscriptionStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1beta1.ChannelDefaulter">ChannelDefaulter
</h3>
<p>
<p>ChannelDefaulter sets the default Channel CRD and Arguments on Channels that do not
specify any implementation.</p>
</p>
<h3 id="messaging.knative.dev/v1beta1.ChannelSpec">ChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.Channel">Channel</a>)
</p>
<p>
<p>ChannelSpec defines which subscribers have expressed interest in receiving events from this Channel.
It also defines the ChannelTemplate to use in order to create the CRD Channel backing this Channel.</p>
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
<a href="#messaging.knative.dev/v1beta1.ChannelTemplateSpec">
ChannelTemplateSpec
</a>
</em>
</td>
<td>
<p>ChannelTemplate specifies which Channel CRD to use to create the CRD Channel backing this Channel.
This is immutable after creation. Normally this is set by the Channel defaulter, not directly by the user.</p>
</td>
</tr>
<tr>
<td>
<code>ChannelableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">
ChannelableSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ChannelableSpec</code> are embedded into this type.)
</p>
<p>Channel conforms to ChannelableSpec</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1beta1.ChannelStatus">ChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.Channel">Channel</a>)
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
<code>ChannelableStatus</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableStatus">
ChannelableStatus
</a>
</em>
</td>
<td>
<p>
(Members of <code>ChannelableStatus</code> are embedded into this type.)
</p>
<p>Channel conforms to ChannelableStatus</p>
</td>
</tr>
<tr>
<td>
<code>channel</code></br>
<em>
knative.dev/pkg/apis/duck/v1.KReference
</em>
</td>
<td>
<p>Channel is an KReference to the Channel CRD backing this Channel.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1beta1.ChannelTemplateSpec">ChannelTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#eventing.knative.dev/v1alpha1.BrokerSpec">BrokerSpec</a>, 
<a href="#messaging.knative.dev/v1beta1.ChannelSpec">ChannelSpec</a>, 
<a href="#messaging.knative.dev/v1alpha1.ChannelSpec">ChannelSpec</a>, 
<a href="#flows.knative.dev/v1alpha1.ParallelSpec">ParallelSpec</a>, 
<a href="#flows.knative.dev/v1beta1.ParallelSpec">ParallelSpec</a>, 
<a href="#flows.knative.dev/v1beta1.SequenceSpec">SequenceSpec</a>, 
<a href="#flows.knative.dev/v1alpha1.SequenceSpec">SequenceSpec</a>)
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
<h3 id="messaging.knative.dev/v1beta1.ChannelTemplateSpecInternal">ChannelTemplateSpecInternal
</h3>
<p>
<p>ChannelTemplateSpecInternal is an internal only version that includes ObjectMeta so that
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
<h3 id="messaging.knative.dev/v1beta1.InMemoryChannelSpec">InMemoryChannelSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.InMemoryChannel">InMemoryChannel</a>)
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
<code>ChannelableSpec</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableSpec">
ChannelableSpec
</a>
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
<h3 id="messaging.knative.dev/v1beta1.InMemoryChannelStatus">InMemoryChannelStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.InMemoryChannel">InMemoryChannel</a>)
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
<code>ChannelableStatus</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.ChannelableStatus">
ChannelableStatus
</a>
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
<h3 id="messaging.knative.dev/v1beta1.SubscriptionSpec">SubscriptionSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.Subscription">Subscription</a>)
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
<code>channel</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#objectreference-v1-core">
Kubernetes core/v1.ObjectReference
</a>
</em>
</td>
<td>
<p>Reference to a channel that will be used to create the subscription
You can specify only the following fields of the ObjectReference:
- Kind
- APIVersion
- Name
The resource pointed by this ObjectReference must meet the
contract to the ChannelableSpec duck type. If the resource does not
meet this contract it will be reflected in the Subscription&rsquo;s status.</p>
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
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Subscriber is reference to (optional) function for processing events.
Events from the Channel will be delivered here and replies are
sent to a Destination as specified by the Reply.</p>
</td>
</tr>
<tr>
<td>
<code>reply</code></br>
<em>
knative.dev/pkg/apis/duck/v1.Destination
</em>
</td>
<td>
<em>(Optional)</em>
<p>Reply specifies (optionally) how to handle events returned from
the Subscriber target.</p>
</td>
</tr>
<tr>
<td>
<code>delivery</code></br>
<em>
<a href="#duck.knative.dev/v1beta1.DeliverySpec">
DeliverySpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Delivery configuration</p>
</td>
</tr>
</tbody>
</table>
<h3 id="messaging.knative.dev/v1beta1.SubscriptionStatus">SubscriptionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.Subscription">Subscription</a>)
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
<code>physicalSubscription</code></br>
<em>
<a href="#messaging.knative.dev/v1beta1.SubscriptionStatusPhysicalSubscription">
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
<h3 id="messaging.knative.dev/v1beta1.SubscriptionStatusPhysicalSubscription">SubscriptionStatusPhysicalSubscription
</h3>
<p>
(<em>Appears on:</em>
<a href="#messaging.knative.dev/v1beta1.SubscriptionStatus">SubscriptionStatus</a>)
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
<code>subscriberUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>SubscriberURI is the fully resolved URI for spec.subscriber.</p>
</td>
</tr>
<tr>
<td>
<code>replyUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>ReplyURI is the fully resolved URI for the spec.reply.</p>
</td>
</tr>
<tr>
<td>
<code>deadLetterSinkUri</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<p>ReplyURI is the fully resolved URI for the spec.delivery.deadLetterSink.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="configs.internal.knative.dev/v1alpha1">configs.internal.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagation">ConfigMapPropagation</a>
</li></ul>
<h3 id="configs.internal.knative.dev/v1alpha1.ConfigMapPropagation">ConfigMapPropagation
</h3>
<p>
<p>ConfigMapPropagation is used to propagate configMaps from original namespace to current namespace</p>
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
configs.internal.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>ConfigMapPropagation</code></td>
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
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagationSpec">
ConfigMapPropagationSpec
</a>
</em>
</td>
<td>
<p>Spec defines the desired state of the ConfigMapPropagation</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>originalNamespace</code></br>
<em>
string
</em>
</td>
<td>
<p>OriginalNamespace is the namespace where the original configMaps are in</p>
</td>
</tr>
<tr>
<td>
<code>selector</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#labelselector-v1-meta">
Kubernetes meta/v1.LabelSelector
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Selector only selects original configMaps with corresponding labels</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagationStatus">
ConfigMapPropagationStatus
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
<h3 id="configs.internal.knative.dev/v1alpha1.ConfigMapPropagationSpec">ConfigMapPropagationSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagation">ConfigMapPropagation</a>)
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
<code>originalNamespace</code></br>
<em>
string
</em>
</td>
<td>
<p>OriginalNamespace is the namespace where the original configMaps are in</p>
</td>
</tr>
<tr>
<td>
<code>selector</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#labelselector-v1-meta">
Kubernetes meta/v1.LabelSelector
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Selector only selects original configMaps with corresponding labels</p>
</td>
</tr>
</tbody>
</table>
<h3 id="configs.internal.knative.dev/v1alpha1.ConfigMapPropagationStatus">ConfigMapPropagationStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagation">ConfigMapPropagation</a>)
</p>
<p>
<p>ConfigMapPropagationStatus represents the current state of a ConfigMapPropagation.</p>
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
<code>copyConfigmaps</code></br>
<em>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagationStatusCopyConfigMap">
[]ConfigMapPropagationStatusCopyConfigMap
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>CopyConfigMaps is the status for each copied configmap.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="configs.internal.knative.dev/v1alpha1.ConfigMapPropagationStatusCopyConfigMap">ConfigMapPropagationStatusCopyConfigMap
</h3>
<p>
(<em>Appears on:</em>
<a href="#configs.internal.knative.dev/v1alpha1.ConfigMapPropagationStatus">ConfigMapPropagationStatus</a>)
</p>
<p>
<p>ConfigMapPropagationStatusCopyConfigMap represents the status of a copied configmap</p>
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
<code>name</code></br>
<em>
string
</em>
</td>
<td>
<p>Name is copy configmap&rsquo;s name</p>
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
<p>Source is &ldquo;originalNamespace/originalConfigMapName&rdquo;</p>
</td>
</tr>
<tr>
<td>
<code>operation</code></br>
<em>
string
</em>
</td>
<td>
<p>Operation represents the operation CMP takes for this configmap. The operations are copy|delete|stop</p>
</td>
</tr>
<tr>
<td>
<code>ready</code></br>
<em>
string
</em>
</td>
<td>
<p>Ready represents the operation is ready or not</p>
</td>
</tr>
<tr>
<td>
<code>reason</code></br>
<em>
string
</em>
</td>
<td>
<p>Reason indicates reasons if the operation is not ready</p>
</td>
</tr>
<tr>
<td>
<code>resourceVersionFromSource</code></br>
<em>
string
</em>
</td>
<td>
<p>ResourceVersion is the resourceVersion of original configmap</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>02bc5166</code>.
</em></p>
