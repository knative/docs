<p>Packages:</p>
<ul>
<li>
<a href="#serving.knative.dev%2fv1beta1">serving.knative.dev/v1beta1</a>
</li>
<li>
<a href="#serving.knative.dev%2fv1">serving.knative.dev/v1</a>
</li>
<li>
<a href="#serving.knative.dev%2fv1alpha1">serving.knative.dev/v1alpha1</a>
</li>
</ul>
<h2 id="serving.knative.dev/v1beta1">serving.knative.dev/v1beta1</h2>
<p>
</p>
Resource Types:
<ul><li>
<a href="#serving.knative.dev/v1beta1.Configuration">Configuration</a>
</li><li>
<a href="#serving.knative.dev/v1beta1.Revision">Revision</a>
</li><li>
<a href="#serving.knative.dev/v1beta1.Route">Route</a>
</li><li>
<a href="#serving.knative.dev/v1beta1.Service">Service</a>
</li></ul>
<h3 id="serving.knative.dev/v1beta1.Configuration">Configuration
</h3>
<p>
<p>Configuration represents the &ldquo;floating HEAD&rdquo; of a linear history of Revisions.
Users create new Revisions by updating the Configuration&rsquo;s spec.
The &ldquo;latest created&rdquo; revision&rsquo;s name is available under status, as is the
&ldquo;latest ready&rdquo; revision&rsquo;s name.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration">https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration</a></p>
</p>
<table>
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
serving.knative.dev/v1beta1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Configuration</code></td>
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
<a href="#serving.knative.dev/v1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template holds the latest specification for the Revision to be stamped out.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationStatus">
ConfigurationStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1beta1.Revision">Revision
</h3>
<p>
<p>Revision is an immutable snapshot of code and configuration.  A revision
references a container image. Revisions are created by updates to a
Configuration.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision">https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision</a></p>
</p>
<table>
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
serving.knative.dev/v1beta1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Revision</code></td>
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
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>PodSpec</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podspec-v1-core">
Kubernetes core/v1.PodSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>PodSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>containerConcurrency</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerConcurrency specifies the maximum allowed in-flight (concurrent)
requests per container of the Revision.  Defaults to <code>0</code> which means
concurrency to the application is not limited, and the system decides the
target concurrency for the autoscaler.</p>
</td>
</tr>
<tr>
<td>
<code>timeoutSeconds</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TimeoutSeconds holds the max duration the instance is allowed for
responding to a request.  If unspecified, a system default will
be provided.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionStatus">
RevisionStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1beta1.Route">Route
</h3>
<p>
<p>Route is responsible for configuring ingress over a collection of Revisions.
Some of the Revisions a Route distributes traffic over may be specified by
referencing the Configuration responsible for creating them; in these cases
the Route is additionally responsible for monitoring the Configuration for
&ldquo;latest ready revision&rdquo; changes, and smoothly rolling out latest revisions.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#route">https://github.com/knative/serving/blob/master/docs/spec/overview.md#route</a></p>
</p>
<table>
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
serving.knative.dev/v1beta1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Route</code></td>
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
<a href="#serving.knative.dev/v1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec holds the desired state of the Route (from the client).</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic specifies how to distribute traffic over a collection of
revisions and configurations.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteStatus">
RouteStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status communicates the observed state of the Route (from the controller).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1beta1.Service">Service
</h3>
<p>
<p>Service acts as a top-level container that manages a Route and Configuration
which implement a network service. Service exists to provide a singular
abstraction which can be access controlled, reasoned about, and which
encapsulates software lifecycle decisions such as rollout policy and
team resource ownership. Service acts only as an orchestrator of the
underlying Routes and Configurations (much as a kubernetes Deployment
orchestrates ReplicaSets), and its usage is optional but recommended.</p>
<p>The Service&rsquo;s controller will track the statuses of its owned Configuration
and Route, reflecting their statuses and conditions as its own.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#service">https://github.com/knative/serving/blob/master/docs/spec/overview.md#service</a></p>
</p>
<table>
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
serving.knative.dev/v1beta1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Service</code></td>
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
<a href="#serving.knative.dev/v1.ServiceSpec">
ServiceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>ConfigurationSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines an unrestricted ConfigurationSpec.</p>
</td>
</tr>
<tr>
<td>
<code>RouteSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines RouteSpec and restricts/defaults its fields
via webhook.  In particular, this spec can only reference this
Service&rsquo;s configuration and revisions (which also influences
defaults).</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.ServiceStatus">
ServiceStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="serving.knative.dev/v1">serving.knative.dev/v1</h2>
<p>
</p>
Resource Types:
<ul><li>
<a href="#serving.knative.dev/v1.Configuration">Configuration</a>
</li><li>
<a href="#serving.knative.dev/v1.Revision">Revision</a>
</li><li>
<a href="#serving.knative.dev/v1.Route">Route</a>
</li><li>
<a href="#serving.knative.dev/v1.Service">Service</a>
</li></ul>
<h3 id="serving.knative.dev/v1.Configuration">Configuration
</h3>
<p>
<p>Configuration represents the &ldquo;floating HEAD&rdquo; of a linear history of Revisions.
Users create new Revisions by updating the Configuration&rsquo;s spec.
The &ldquo;latest created&rdquo; revision&rsquo;s name is available under status, as is the
&ldquo;latest ready&rdquo; revision&rsquo;s name.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration">https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration</a></p>
</p>
<table>
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
serving.knative.dev/v1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Configuration</code></td>
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
<a href="#serving.knative.dev/v1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template holds the latest specification for the Revision to be stamped out.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationStatus">
ConfigurationStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.Revision">Revision
</h3>
<p>
<p>Revision is an immutable snapshot of code and configuration.  A revision
references a container image. Revisions are created by updates to a
Configuration.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision">https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision</a></p>
</p>
<table>
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
serving.knative.dev/v1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Revision</code></td>
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
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>PodSpec</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podspec-v1-core">
Kubernetes core/v1.PodSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>PodSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>containerConcurrency</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerConcurrency specifies the maximum allowed in-flight (concurrent)
requests per container of the Revision.  Defaults to <code>0</code> which means
concurrency to the application is not limited, and the system decides the
target concurrency for the autoscaler.</p>
</td>
</tr>
<tr>
<td>
<code>timeoutSeconds</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TimeoutSeconds holds the max duration the instance is allowed for
responding to a request.  If unspecified, a system default will
be provided.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionStatus">
RevisionStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.Route">Route
</h3>
<p>
<p>Route is responsible for configuring ingress over a collection of Revisions.
Some of the Revisions a Route distributes traffic over may be specified by
referencing the Configuration responsible for creating them; in these cases
the Route is additionally responsible for monitoring the Configuration for
&ldquo;latest ready revision&rdquo; changes, and smoothly rolling out latest revisions.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#route">https://github.com/knative/serving/blob/master/docs/spec/overview.md#route</a></p>
</p>
<table>
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
serving.knative.dev/v1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Route</code></td>
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
<a href="#serving.knative.dev/v1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec holds the desired state of the Route (from the client).</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic specifies how to distribute traffic over a collection of
revisions and configurations.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteStatus">
RouteStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status communicates the observed state of the Route (from the controller).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.Service">Service
</h3>
<p>
<p>Service acts as a top-level container that manages a Route and Configuration
which implement a network service. Service exists to provide a singular
abstraction which can be access controlled, reasoned about, and which
encapsulates software lifecycle decisions such as rollout policy and
team resource ownership. Service acts only as an orchestrator of the
underlying Routes and Configurations (much as a kubernetes Deployment
orchestrates ReplicaSets), and its usage is optional but recommended.</p>
<p>The Service&rsquo;s controller will track the statuses of its owned Configuration
and Route, reflecting their statuses and conditions as its own.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#service">https://github.com/knative/serving/blob/master/docs/spec/overview.md#service</a></p>
</p>
<table>
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
serving.knative.dev/v1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Service</code></td>
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
<a href="#serving.knative.dev/v1.ServiceSpec">
ServiceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>ConfigurationSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines an unrestricted ConfigurationSpec.</p>
</td>
</tr>
<tr>
<td>
<code>RouteSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines RouteSpec and restricts/defaults its fields
via webhook.  In particular, this spec can only reference this
Service&rsquo;s configuration and revisions (which also influences
defaults).</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1.ServiceStatus">
ServiceStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.ConfigurationSpec">ConfigurationSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Configuration">Configuration</a>, 
<a href="#serving.knative.dev/v1.Configuration">Configuration</a>,
<a href="#serving.knative.dev/v1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>ConfigurationSpec holds the desired state of the Configuration (from the client).</p>
</p>
<table>
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
<a href="#serving.knative.dev/v1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template holds the latest specification for the Revision to be stamped out.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.ConfigurationStatus">ConfigurationStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Configuration">Configuration</a>,
<a href="#serving.knative.dev/v1.Configuration">Configuration</a>)
</p>
<p>
<p>ConfigurationStatus communicates the observed state of the Configuration (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>ConfigurationStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationStatusFields">
ConfigurationStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.ConfigurationStatusFields">ConfigurationStatusFields
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1.ConfigurationStatus">ConfigurationStatus</a>, 
<a href="#serving.knative.dev/v1.ServiceStatus">ServiceStatus</a>)
</p>
<p>
<p>ConfigurationStatusFields holds the fields of Configuration&rsquo;s status that
are not generally shared.  This is defined separately and inlined so that
other types can readily consume these fields via duck typing.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>latestReadyRevisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LatestReadyRevisionName holds the name of the latest Revision stamped out
from this Configuration that has had its &ldquo;Ready&rdquo; condition become &ldquo;True&rdquo;.</p>
</td>
</tr>
<tr>
<td>
<code>latestCreatedRevisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LatestCreatedRevisionName is the last revision that was created from this
Configuration. It might not be ready yet, for that use LatestReadyRevisionName.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.ContainerStatuses">ContainerStatuses
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1.RevisionStatus">RevisionStatus</a>)
</p>
<p>
<p>ContainerStatuses holds the information of container name and image digest value</p>
</p>
<table>
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
</td>
</tr>
<tr>
<td>
<code>imageDigest</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RevisionSpec">RevisionSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Revision">Revision</a>, 
<a href="#serving.knative.dev/v1.Revision">Revision</a>, 
<a href="#serving.knative.dev/v1alpha1.RevisionSpec">RevisionSpec</a>, 
<a href="#serving.knative.dev/v1.RevisionTemplateSpec">RevisionTemplateSpec</a>)
</p>
<p>
<p>RevisionSpec holds the desired state of the Revision (from the client).</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>PodSpec</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podspec-v1-core">
Kubernetes core/v1.PodSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>PodSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>containerConcurrency</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerConcurrency specifies the maximum allowed in-flight (concurrent)
requests per container of the Revision.  Defaults to <code>0</code> which means
concurrency to the application is not limited, and the system decides the
target concurrency for the autoscaler.</p>
</td>
</tr>
<tr>
<td>
<code>timeoutSeconds</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TimeoutSeconds holds the max duration the instance is allowed for
responding to a request.  If unspecified, a system default will
be provided.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RevisionStatus">RevisionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Revision">Revision</a>, 
<a href="#serving.knative.dev/v1.Revision">Revision</a>)
</p>
<p>
<p>RevisionStatus communicates the observed state of the Revision (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>serviceName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceName holds the name of a core Kubernetes Service resource that
load balances over the pods backing this Revision.</p>
</td>
</tr>
<tr>
<td>
<code>logUrl</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LogURL specifies the generated logging url for this particular revision
based on the revision url template specified in the controller&rsquo;s config.</p>
</td>
</tr>
<tr>
<td>
<code>imageDigest</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedImageDigest holds the resolved digest for the image specified
within .Spec.Container.Image. The digest is resolved during the creation
of Revision. This field holds the digest value regardless of whether
a tag or digest was originally specified in the Container object. It
may be empty if the image comes from a registry listed to skip resolution.
If multiple containers specified then DeprecatedImageDigest holds the digest
for serving container.
DEPRECATED: Use ContainerStatuses instead.
TODO(savitaashture) Remove deprecatedImageDigest.
ref <a href="https://kubernetes.io/docs/reference/using-api/deprecation-policy">https://kubernetes.io/docs/reference/using-api/deprecation-policy</a> for deprecation.</p>
</td>
</tr>
<tr>
<td>
<code>containerStatuses</code></br>
<em>
<a href="#serving.knative.dev/v1.ContainerStatuses">
[]ContainerStatuses
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerStatuses is a slice of images present in .Spec.Container[*].Image
to their respective digests and their container name.
The digests are resolved during the creation of Revision.
ContainerStatuses holds the container name and image digests
for both serving and non serving containers.
ref: <a href="http://bit.ly/image-digests">http://bit.ly/image-digests</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RevisionTemplateSpec">RevisionTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1.ConfigurationSpec">ConfigurationSpec</a>)
</p>
<p>
<p>RevisionTemplateSpec describes the data a revision should have when created from a template.
Based on: <a href="https://github.com/kubernetes/api/blob/e771f807/core/v1/types.go#L3179-L3190">https://github.com/kubernetes/api/blob/e771f807/core/v1/types.go#L3179-L3190</a></p>
</p>
<table>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>PodSpec</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#podspec-v1-core">
Kubernetes core/v1.PodSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>PodSpec</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>containerConcurrency</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerConcurrency specifies the maximum allowed in-flight (concurrent)
requests per container of the Revision.  Defaults to <code>0</code> which means
concurrency to the application is not limited, and the system decides the
target concurrency for the autoscaler.</p>
</td>
</tr>
<tr>
<td>
<code>timeoutSeconds</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>TimeoutSeconds holds the max duration the instance is allowed for
responding to a request.  If unspecified, a system default will
be provided.</p>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RouteSpec">RouteSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Route">Route</a>, 
<a href="#serving.knative.dev/v1.Route">Route</a>, 
<a href="#serving.knative.dev/v1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>RouteSpec holds the desired state of the Route (from the client).</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic specifies how to distribute traffic over a collection of
revisions and configurations.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RouteStatus">RouteStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Route">Route</a>, 
<a href="#serving.knative.dev/v1.Route">Route</a>)
</p>
<p>
<p>RouteStatus communicates the observed state of the Route (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>RouteStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteStatusFields">
RouteStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RouteStatusFields">RouteStatusFields
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1.RouteStatus">RouteStatus</a>, 
<a href="#serving.knative.dev/v1.ServiceStatus">ServiceStatus</a>)
</p>
<p>
<p>RouteStatusFields holds the fields of Route&rsquo;s status that
are not generally shared.  This is defined separately and inlined so that
other types can readily consume these fields via duck typing.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>url</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>URL holds the url that will distribute traffic over the provided traffic targets.
It generally has the form http[s]://{route-name}.{route-namespace}.{cluster-level-suffix}</p>
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
<em>(Optional)</em>
<p>Address holds the information needed for a Route to be the target of an event.</p>
</td>
</tr>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic holds the configured traffic distribution.
These entries will always contain RevisionName references.
When ConfigurationName appears in the spec, this will hold the
LatestReadyRevisionName that we last observed.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.RoutingState">RoutingState
(<code>string</code> alias)</p></h3>
<p>
<p>RoutingState represents states of a revision with regards to serving a route.</p>
</p>
<h3 id="serving.knative.dev/v1.ServiceSpec">ServiceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Service">Service</a>, 
<a href="#serving.knative.dev/v1.Service">Service</a>)
</p>
<p>
<p>ServiceSpec represents the configuration for the Service object.
A Service&rsquo;s specification is the union of the specifications for a Route
and Configuration.  The Service restricts what can be expressed in these
fields, e.g. the Route must reference the provided Configuration;
however, these limitations also enable friendlier defaulting,
e.g. Route never needs a Configuration name, and may be defaulted to
the appropriate &ldquo;run latest&rdquo; spec.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>ConfigurationSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines an unrestricted ConfigurationSpec.</p>
</td>
</tr>
<tr>
<td>
<code>RouteSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteSpec</code> are embedded into this type.)
</p>
<p>ServiceSpec inlines RouteSpec and restricts/defaults its fields
via webhook.  In particular, this spec can only reference this
Service&rsquo;s configuration and revisions (which also influences
defaults).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.ServiceStatus">ServiceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1beta1.Service">Service</a>, 
<a href="#serving.knative.dev/v1.Service">Service</a>)
</p>
<p>
<p>ServiceStatus represents the Status stanza of the Service resource.</p>
</p>
<table>
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
<tr>
<td>
<code>ConfigurationStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1.ConfigurationStatusFields">
ConfigurationStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationStatusFields</code> are embedded into this type.)
</p>
<p>In addition to inlining ConfigurationSpec, we also inline the fields
specific to ConfigurationStatus.</p>
</td>
</tr>
<tr>
<td>
<code>RouteStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1.RouteStatusFields">
RouteStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteStatusFields</code> are embedded into this type.)
</p>
<p>In addition to inlining RouteSpec, we also inline the fields
specific to RouteStatus.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1.TrafficTarget">TrafficTarget
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1.RouteSpec">RouteSpec</a>, 
<a href="#serving.knative.dev/v1.RouteStatusFields">RouteStatusFields</a>, 
<a href="#serving.knative.dev/v1alpha1.TrafficTarget">TrafficTarget</a>)
</p>
<p>
<p>TrafficTarget holds a single entry of the routing table for a Route.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>tag</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Tag is optionally used to expose a dedicated url for referencing
this target exclusively.</p>
</td>
</tr>
<tr>
<td>
<code>revisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>RevisionName of a specific revision to which to send this portion of
traffic.  This is mutually exclusive with ConfigurationName.</p>
</td>
</tr>
<tr>
<td>
<code>configurationName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ConfigurationName of a configuration to whose latest revision we will send
this portion of traffic. When the &ldquo;status.latestReadyRevisionName&rdquo; of the
referenced configuration changes, we will automatically migrate traffic
from the prior &ldquo;latest ready&rdquo; revision to the new one.  This field is never
set in Route&rsquo;s status, only its spec.  This is mutually exclusive with
RevisionName.</p>
</td>
</tr>
<tr>
<td>
<code>latestRevision</code></br>
<em>
bool
</em>
</td>
<td>
<em>(Optional)</em>
<p>LatestRevision may be optionally provided to indicate that the latest
ready Revision of the Configuration should be used for this traffic
target.  When provided LatestRevision must be true if RevisionName is
empty; it must be false when RevisionName is non-empty.</p>
</td>
</tr>
<tr>
<td>
<code>percent</code></br>
<em>
int64
</em>
</td>
<td>
<em>(Optional)</em>
<p>Percent indicates that percentage based routing should be used and
the value indicates the percent of traffic that is be routed to this
Revision or Configuration. <code>0</code> (zero) mean no traffic, <code>100</code> means all
traffic.
When percentage based routing is being used the follow rules apply:
- the sum of all percent values must equal 100
- when not specified, the implied value for <code>percent</code> is zero for
that particular Revision or Configuration</p>
</td>
</tr>
<tr>
<td>
<code>url</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>URL displays the URL for accessing named traffic targets. URL is displayed in
status, and is disallowed on spec. URL must contain a scheme (e.g. http://) and
a hostname, but may not contain anything else (e.g. basic auth, url path, etc.)</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<h2 id="serving.knative.dev/v1alpha1">serving.knative.dev/v1alpha1</h2>
<p>
</p>
Resource Types:
<ul><li>
<a href="#serving.knative.dev/v1alpha1.Configuration">Configuration</a>
</li><li>
<a href="#serving.knative.dev/v1alpha1.Revision">Revision</a>
</li><li>
<a href="#serving.knative.dev/v1alpha1.Route">Route</a>
</li><li>
<a href="#serving.knative.dev/v1alpha1.Service">Service</a>
</li></ul>
<h3 id="serving.knative.dev/v1alpha1.Configuration">Configuration
</h3>
<p>
<p>Configuration represents the &ldquo;floating HEAD&rdquo; of a linear history of Revisions,
and optionally how the containers those revisions reference are built.
Users create new Revisions by updating the Configuration&rsquo;s spec.
The &ldquo;latest created&rdquo; revision&rsquo;s name is available under status, as is the
&ldquo;latest ready&rdquo; revision&rsquo;s name.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration">https://github.com/knative/serving/blob/master/docs/spec/overview.md#configuration</a></p>
</p>
<table>
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
serving.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Configuration</code></td>
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
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec holds the desired state of the Configuration (from the client).</p>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>build</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Build optionally holds the specification for the build to
perform to produce the Revision&rsquo;s container image.</p>
</td>
</tr>
<tr>
<td>
<code>revisionTemplate</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedRevisionTemplate holds the latest specification for the Revision to
be stamped out. If a Build specification is provided, then the
DeprecatedRevisionTemplate&rsquo;s BuildName field will be populated with the name of
the Build object created to produce the container for the Revision.
DEPRECATED Use Template instead.</p>
</td>
</tr>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template holds the latest specification for the Revision to
be stamped out.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationStatus">
ConfigurationStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status communicates the observed state of the Configuration (from the controller).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.Revision">Revision
</h3>
<p>
<p>Revision is an immutable snapshot of code and configuration.  A revision
references a container image, and optionally a build that is responsible for
materializing that container image from source. Revisions are created by
updates to a Configuration.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision">https://github.com/knative/serving/blob/master/docs/spec/overview.md#revision</a></p>
</p>
<table>
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
serving.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Revision</code></td>
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
<a href="#serving.knative.dev/v1alpha1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec holds the desired state of the Revision (from the client).</p>
<br/>
<br/>
<table>
<tr>
<td>
<code>RevisionSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RevisionSpec</code> are embedded into this type.)
</p>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>servingState</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.DeprecatedRevisionServingStateType">
DeprecatedRevisionServingStateType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedServingState holds a value describing the desired state the Kubernetes
resources should be in for this Revision.
Users must not specify this when creating a revision. These values are no longer
updated by the system.</p>
</td>
</tr>
<tr>
<td>
<code>container</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core">
Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedContainer defines the unit of execution for this Revision.
In the context of a Revision, we disallow a number of the fields of
this Container, including: name and lifecycle.
See also the runtime contract for more information about the execution
environment:
<a href="https://github.com/knative/serving/blob/master/docs/runtime-contract.md">https://github.com/knative/serving/blob/master/docs/runtime-contract.md</a></p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionStatus">
RevisionStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status communicates the observed state of the Revision (from the controller).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.Route">Route
</h3>
<p>
<p>Route is responsible for configuring ingress over a collection of Revisions.
Some of the Revisions a Route distributes traffic over may be specified by
referencing the Configuration responsible for creating them; in these cases
the Route is additionally responsible for monitoring the Configuration for
&ldquo;latest ready&rdquo; revision changes, and smoothly rolling out latest revisions.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#route">https://github.com/knative/serving/blob/master/docs/spec/overview.md#route</a></p>
</p>
<table>
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
serving.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Route</code></td>
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
<a href="#serving.knative.dev/v1alpha1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Spec holds the desired state of the Route (from the client).</p>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic specifies how to distribute traffic over a collection of Knative Serving Revisions and Configurations.</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RouteStatus">
RouteStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Status communicates the observed state of the Route (from the controller).</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.Service">Service
</h3>
<p>
<p>Service acts as a top-level container that manages a set of Routes and
Configurations which implement a network service. Service exists to provide a
singular abstraction which can be access controlled, reasoned about, and
which encapsulates software lifecycle decisions such as rollout policy and
team resource ownership. Service acts only as an orchestrator of the
underlying Routes and Configurations (much as a kubernetes Deployment
orchestrates ReplicaSets), and its usage is optional but recommended.</p>
<p>The Service&rsquo;s controller will track the statuses of its owned Configuration
and Route, reflecting their statuses and conditions as its own.</p>
<p>See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/overview.md#service">https://github.com/knative/serving/blob/master/docs/spec/overview.md#service</a></p>
</p>
<table>
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
serving.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Service</code></td>
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
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">
ServiceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>runLatest</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RunLatestType">
RunLatestType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedRunLatest defines a simple Service. It will automatically
configure a route that keeps the latest ready revision
from the supplied configuration running.</p>
</td>
</tr>
<tr>
<td>
<code>pinned</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.PinnedType">
PinnedType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedPinned is DEPRECATED in favor of ReleaseType</p>
</td>
</tr>
<tr>
<td>
<code>manual</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ManualType">
ManualType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedManual mode enables users to start managing the underlying Route and Configuration
resources directly.  This advanced usage is intended as a path for users to graduate
from the limited capabilities of Service to the full power of Route.</p>
</td>
</tr>
<tr>
<td>
<code>release</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ReleaseType">
ReleaseType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Release enables gradual promotion of new revisions by allowing traffic
to be split between two revisions. This type replaces the deprecated Pinned type.</p>
</td>
</tr>
<tr>
<td>
<code>ConfigurationSpec</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationSpec</code> are embedded into this type.)
</p>
<p>We are moving to a shape where the Configuration and Route specifications
are inlined into the Service, which gives them compatible shapes.  We are
staging this change here as a path to this in v1beta1, which drops the
&ldquo;mode&rdquo; based specifications above.  Ultimately all non-v1beta1 fields will
be deprecated, and then dropped in v1beta1.</p>
</td>
</tr>
<tr>
<td>
<code>RouteSpec</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteSpec</code> are embedded into this type.)
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
<a href="#serving.knative.dev/v1alpha1.ServiceStatus">
ServiceStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.CannotConvertError">CannotConvertError
</h3>
<p>
<p>CannotConvertError is returned when a field cannot be converted.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>Message</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
<tr>
<td>
<code>Field</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ConfigurationSpec">ConfigurationSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Configuration">Configuration</a>, 
<a href="#serving.knative.dev/v1alpha1.PinnedType">PinnedType</a>, 
<a href="#serving.knative.dev/v1alpha1.ReleaseType">ReleaseType</a>, 
<a href="#serving.knative.dev/v1alpha1.RunLatestType">RunLatestType</a>, 
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>ConfigurationSpec holds the desired state of the Configuration (from the client).</p>
</p>
<table>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>build</code></br>
<em>
k8s.io/apimachinery/pkg/runtime.RawExtension
</em>
</td>
<td>
<em>(Optional)</em>
<p>Build optionally holds the specification for the build to
perform to produce the Revision&rsquo;s container image.</p>
</td>
</tr>
<tr>
<td>
<code>revisionTemplate</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedRevisionTemplate holds the latest specification for the Revision to
be stamped out. If a Build specification is provided, then the
DeprecatedRevisionTemplate&rsquo;s BuildName field will be populated with the name of
the Build object created to produce the container for the Revision.
DEPRECATED Use Template instead.</p>
</td>
</tr>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionTemplateSpec">
RevisionTemplateSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template holds the latest specification for the Revision to
be stamped out.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ConfigurationStatus">ConfigurationStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Configuration">Configuration</a>)
</p>
<p>
<p>ConfigurationStatus communicates the observed state of the Configuration (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>ConfigurationStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationStatusFields">
ConfigurationStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ConfigurationStatusFields">ConfigurationStatusFields
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationStatus">ConfigurationStatus</a>, 
<a href="#serving.knative.dev/v1alpha1.ServiceStatus">ServiceStatus</a>)
</p>
<p>
<p>ConfigurationStatusFields holds all of the non-duckv1.Status status fields of a Route.
These are defined outline so that we can also inline them into Service, and more easily
copy them.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>latestReadyRevisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LatestReadyRevisionName holds the name of the latest Revision stamped out
from this Configuration that has had its &ldquo;Ready&rdquo; condition become &ldquo;True&rdquo;.</p>
</td>
</tr>
<tr>
<td>
<code>latestCreatedRevisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LatestCreatedRevisionName is the last revision that was created from this
Configuration. It might not be ready yet, for that use LatestReadyRevisionName.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ContainerStatuses">ContainerStatuses
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.RevisionStatus">RevisionStatus</a>)
</p>
<p>
<p>ContainerStatuses holds the information of container name and image digest value</p>
</p>
<table>
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
</td>
</tr>
<tr>
<td>
<code>imageDigest</code></br>
<em>
string
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.DeprecatedRevisionServingStateType">DeprecatedRevisionServingStateType
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.RevisionSpec">RevisionSpec</a>)
</p>
<p>
<p>DeprecatedRevisionServingStateType is an enumeration of the levels of serving readiness of the Revision.
See also: <a href="https://github.com/knative/serving/blob/master/docs/spec/errors.md#error-conditions-and-reporting">https://github.com/knative/serving/blob/master/docs/spec/errors.md#error-conditions-and-reporting</a></p>
</p>
<h3 id="serving.knative.dev/v1alpha1.ManualType">ManualType
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>ManualType contains the options for configuring a manual service. See ServiceSpec for
more details.</p>
</p>
<h3 id="serving.knative.dev/v1alpha1.PinnedType">PinnedType
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>PinnedType is DEPRECATED. ReleaseType should be used instead. To get the behavior of PinnedType set
ReleaseType.Revisions to []string{PinnedType.RevisionName} and ReleaseType.RolloutPercent to 0.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>revisionName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>The revision name to pin this service to until changed
to a different service type.</p>
</td>
</tr>
<tr>
<td>
<code>configuration</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>The configuration for this service.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ReleaseType">ReleaseType
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>ReleaseType contains the options for slowly releasing revisions. See ServiceSpec for
more details.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>revisions</code></br>
<em>
[]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Revisions is an ordered list of 1 or 2 revisions. The first will
have a TrafficTarget with a name of &ldquo;current&rdquo; and the second will have
a name of &ldquo;candidate&rdquo;.</p>
</td>
</tr>
<tr>
<td>
<code>rolloutPercent</code></br>
<em>
int
</em>
</td>
<td>
<em>(Optional)</em>
<p>RolloutPercent is the percent of traffic that should be sent to the &ldquo;candidate&rdquo;
revision. Valid values are between 0 and 99 inclusive.</p>
</td>
</tr>
<tr>
<td>
<code>configuration</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>The configuration for this service. All revisions from this service must
come from a single configuration.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RevisionSpec">RevisionSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Revision">Revision</a>, 
<a href="#serving.knative.dev/v1alpha1.RevisionTemplateSpec">RevisionTemplateSpec</a>)
</p>
<p>
<p>RevisionSpec holds the desired state of the Revision (from the client).</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>RevisionSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RevisionSpec</code> are embedded into this type.)
</p>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>servingState</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.DeprecatedRevisionServingStateType">
DeprecatedRevisionServingStateType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedServingState holds a value describing the desired state the Kubernetes
resources should be in for this Revision.
Users must not specify this when creating a revision. These values are no longer
updated by the system.</p>
</td>
</tr>
<tr>
<td>
<code>container</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core">
Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedContainer defines the unit of execution for this Revision.
In the context of a Revision, we disallow a number of the fields of
this Container, including: name and lifecycle.
See also the runtime contract for more information about the execution
environment:
<a href="https://github.com/knative/serving/blob/master/docs/runtime-contract.md">https://github.com/knative/serving/blob/master/docs/runtime-contract.md</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RevisionStatus">RevisionStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Revision">Revision</a>)
</p>
<p>
<p>RevisionStatus communicates the observed state of the Revision (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>serviceName</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>ServiceName holds the name of a core Kubernetes Service resource that
load balances over the pods backing this Revision.</p>
</td>
</tr>
<tr>
<td>
<code>logUrl</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>LogURL specifies the generated logging url for this particular revision
based on the revision url template specified in the controller&rsquo;s config.</p>
</td>
</tr>
<tr>
<td>
<code>imageDigest</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedImageDigest holds the resolved digest for the image specified
within .Spec.Container.Image. The digest is resolved during the creation
of Revision. This field holds the digest value regardless of whether
a tag or digest was originally specified in the Container object. It
may be empty if the image comes from a registry listed to skip resolution.
If multiple containers specified then DeprecatedImageDigest holds the digest
for serving container.
DEPRECATED: Use ContainerStatuses instead.
TODO(savitaashture) Remove deprecatedImageDigest.
ref <a href="https://kubernetes.io/docs/reference/using-api/deprecation-policy">https://kubernetes.io/docs/reference/using-api/deprecation-policy</a> for deprecation.</p>
</td>
</tr>
<tr>
<td>
<code>containerStatuses</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ContainerStatuses">
[]ContainerStatuses
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>ContainerStatuses is a slice of images present in .Spec.Container[*].Image
to their respective digests and their container name.
The digests are resolved during the creation of Revision.
ContainerStatuses holds the container name and image digests
for both serving and non serving containers.
ref: <a href="http://bit.ly/image-digests">http://bit.ly/image-digests</a></p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RevisionTemplateSpec">RevisionTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">ConfigurationSpec</a>)
</p>
<p>
<p>RevisionTemplateSpec describes the data a revision should have when created from a template.
Based on: <a href="https://github.com/kubernetes/api/blob/e771f807/core/v1/types.go#L3179-L3190">https://github.com/kubernetes/api/blob/e771f807/core/v1/types.go#L3179-L3190</a></p>
</p>
<table>
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
<em>(Optional)</em>
Refer to the Kubernetes API documentation for the fields of the
<code>metadata</code> field.
</td>
</tr>
<tr>
<td>
<code>spec</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<br/>
<br/>
<table>
<tr>
<td>
<code>RevisionSpec</code></br>
<em>
<a href="#serving.knative.dev/v1.RevisionSpec">
RevisionSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RevisionSpec</code> are embedded into this type.)
</p>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>servingState</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.DeprecatedRevisionServingStateType">
DeprecatedRevisionServingStateType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedServingState holds a value describing the desired state the Kubernetes
resources should be in for this Revision.
Users must not specify this when creating a revision. These values are no longer
updated by the system.</p>
</td>
</tr>
<tr>
<td>
<code>container</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core">
Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedContainer defines the unit of execution for this Revision.
In the context of a Revision, we disallow a number of the fields of
this Container, including: name and lifecycle.
See also the runtime contract for more information about the execution
environment:
<a href="https://github.com/knative/serving/blob/master/docs/runtime-contract.md">https://github.com/knative/serving/blob/master/docs/runtime-contract.md</a></p>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RouteSpec">RouteSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Route">Route</a>, 
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>RouteSpec holds the desired state of the Route (from the client).</p>
</p>
<table>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic specifies how to distribute traffic over a collection of Knative Serving Revisions and Configurations.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RouteStatus">RouteStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Route">Route</a>)
</p>
<p>
<p>RouteStatus communicates the observed state of the Route (from the controller).</p>
</p>
<table>
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
<tr>
<td>
<code>RouteStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RouteStatusFields">
RouteStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RouteStatusFields">RouteStatusFields
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.RouteStatus">RouteStatus</a>, 
<a href="#serving.knative.dev/v1alpha1.ServiceStatus">ServiceStatus</a>)
</p>
<p>
<p>RouteStatusFields holds all of the non-duckv1.Status status fields of a Route.
These are defined outline so that we can also inline them into Service, and more easily
copy them.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>url</code></br>
<em>
knative.dev/pkg/apis.URL
</em>
</td>
<td>
<em>(Optional)</em>
<p>URL holds the url that will distribute traffic over the provided traffic targets.
It generally has the form http[s]://{route-name}.{route-namespace}.{cluster-level-suffix}</p>
</td>
</tr>
<tr>
<td>
<code>domain</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedDomain holds the top-level domain that will distribute traffic over the provided targets.
It generally has the form {route-name}.{route-namespace}.{cluster-level-suffix}</p>
</td>
</tr>
<tr>
<td>
<code>domainInternal</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedDomainInternal holds the top-level domain that will distribute traffic over the provided
targets from inside the cluster. It generally has the form
{route-name}.{route-namespace}.svc.{cluster-domain-name}
DEPRECATED: Use Address instead.</p>
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
<em>(Optional)</em>
<p>Address holds the information needed for a Route to be the target of an event.</p>
</td>
</tr>
<tr>
<td>
<code>traffic</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.TrafficTarget">
[]TrafficTarget
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Traffic holds the configured traffic distribution.
These entries will always contain RevisionName references.
When ConfigurationName appears in the spec, this will hold the
LatestReadyRevisionName that we last observed.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.RunLatestType">RunLatestType
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec</a>)
</p>
<p>
<p>RunLatestType contains the options for always having a route to the latest configuration. See
ServiceSpec for more details.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>configuration</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>The configuration for this service.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ServiceSpec">ServiceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Service">Service</a>)
</p>
<p>
<p>ServiceSpec represents the configuration for the Service object. Exactly one
of its members (other than Generation) must be specified. Services can either
track the latest ready revision of a configuration or be pinned to a specific
revision.</p>
</p>
<table>
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
<p>DeprecatedGeneration was used prior in Kubernetes versions <1.11
when metadata.generation was not being incremented by the api server</p>
<p>This property will be dropped in future Knative releases and should
not be used - use metadata.generation</p>
<p>Tracking issue: <a href="https://github.com/knative/serving/issues/643">https://github.com/knative/serving/issues/643</a></p>
</td>
</tr>
<tr>
<td>
<code>runLatest</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RunLatestType">
RunLatestType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedRunLatest defines a simple Service. It will automatically
configure a route that keeps the latest ready revision
from the supplied configuration running.</p>
</td>
</tr>
<tr>
<td>
<code>pinned</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.PinnedType">
PinnedType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedPinned is DEPRECATED in favor of ReleaseType</p>
</td>
</tr>
<tr>
<td>
<code>manual</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ManualType">
ManualType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>DeprecatedManual mode enables users to start managing the underlying Route and Configuration
resources directly.  This advanced usage is intended as a path for users to graduate
from the limited capabilities of Service to the full power of Route.</p>
</td>
</tr>
<tr>
<td>
<code>release</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ReleaseType">
ReleaseType
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Release enables gradual promotion of new revisions by allowing traffic
to be split between two revisions. This type replaces the deprecated Pinned type.</p>
</td>
</tr>
<tr>
<td>
<code>ConfigurationSpec</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationSpec">
ConfigurationSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationSpec</code> are embedded into this type.)
</p>
<p>We are moving to a shape where the Configuration and Route specifications
are inlined into the Service, which gives them compatible shapes.  We are
staging this change here as a path to this in v1beta1, which drops the
&ldquo;mode&rdquo; based specifications above.  Ultimately all non-v1beta1 fields will
be deprecated, and then dropped in v1beta1.</p>
</td>
</tr>
<tr>
<td>
<code>RouteSpec</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RouteSpec">
RouteSpec
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteSpec</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.ServiceStatus">ServiceStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.Service">Service</a>)
</p>
<p>
<p>ServiceStatus represents the Status stanza of the Service resource.</p>
</p>
<table>
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
<tr>
<td>
<code>RouteStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.RouteStatusFields">
RouteStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>RouteStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
<tr>
<td>
<code>ConfigurationStatusFields</code></br>
<em>
<a href="#serving.knative.dev/v1alpha1.ConfigurationStatusFields">
ConfigurationStatusFields
</a>
</em>
</td>
<td>
<p>
(Members of <code>ConfigurationStatusFields</code> are embedded into this type.)
</p>
</td>
</tr>
</tbody>
</table>
<h3 id="serving.knative.dev/v1alpha1.TrafficTarget">TrafficTarget
</h3>
<p>
(<em>Appears on:</em>
<a href="#serving.knative.dev/v1alpha1.RouteSpec">RouteSpec</a>, 
<a href="#serving.knative.dev/v1alpha1.RouteStatusFields">RouteStatusFields</a>)
</p>
<p>
<p>TrafficTarget holds a single entry of the routing table for a Route.</p>
</p>
<table>
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
<em>(Optional)</em>
<p>Name is optionally used to expose a dedicated hostname for referencing this
target exclusively. It has the form: {name}.${route.status.domain}</p>
</td>
</tr>
<tr>
<td>
<code>TrafficTarget</code></br>
<em>
<a href="#serving.knative.dev/v1.TrafficTarget">
TrafficTarget
</a>
</em>
</td>
<td>
<p>
(Members of <code>TrafficTarget</code> are embedded into this type.)
</p>
<p>We inherit most of our fields by inlining the v1 type.
Ultimately all non-v1 fields will be deprecated.</p>
</td>
</tr>
</tbody>
</table>
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>427b2bf86</code>.
</em></p>
