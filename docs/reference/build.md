<p>Packages:</p>
<ul>
<li>
<a href="#build.knative.dev%2fv1alpha1">build.knative.dev/v1alpha1</a>
</li>
</ul>
<h2 id="build.knative.dev/v1alpha1">build.knative.dev/v1alpha1</h2>
<p>
<p>Package v1alpha1 is the v1alpha1 version of the API.</p>
</p>
Resource Types:
<ul><li>
<a href="#build.knative.dev/v1alpha1.Build">Build</a>
</li><li>
<a href="#build.knative.dev/v1alpha1.BuildTemplate">BuildTemplate</a>
</li><li>
<a href="#build.knative.dev/v1alpha1.ClusterBuildTemplate">ClusterBuildTemplate</a>
</li></ul>
<h3 id="build.knative.dev/v1alpha1.Build">Build
</h3>
<p>
<p>Build represents a build of a container image. A Build is made up of a
source, and a set of steps. Steps can mount volumes to share data between
themselves. A build may be created by instantiating a BuildTemplate.</p>
</p>
<table>
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
build.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>Build</code></td>
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
<a href="#build.knative.dev/v1alpha1.BuildSpec">
BuildSpec
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
<p>TODO(dprotaso) Metadata.Generation should increment so we
can drop this property when conversion webhooks enable us
to migrate</p>
</td>
</tr>
<tr>
<td>
<code>source</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">
SourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Source specifies the input to the build.</p>
</td>
</tr>
<tr>
<td>
<code>sources</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">
[]SourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sources specifies the inputs to the build.</p>
</td>
</tr>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
[]Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Steps are the steps of the build; each step is run sequentially with the
source mounted into /workspace.</p>
</td>
</tr>
<tr>
<td>
<code>volumes</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">
[]Kubernetes core/v1.Volume
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Volumes is a collection of volumes that are available to mount into the
steps of the build.</p>
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
<p>The name of the service account as which to run this build.</p>
</td>
</tr>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.TemplateInstantiationSpec">
TemplateInstantiationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template, if specified, references a BuildTemplate resource to use to
populate fields in the build, and optional Arguments to pass to the
template. The default Kind of template is BuildTemplate</p>
</td>
</tr>
<tr>
<td>
<code>nodeSelector</code></br>
<em>
map[string]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>NodeSelector is a selector which must be true for the pod to fit on a node.
Selector which must match a node&rsquo;s labels for the pod to be scheduled on that node.
More info: <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/">https://kubernetes.io/docs/concepts/configuration/assign-pod-node/</a></p>
</td>
</tr>
<tr>
<td>
<code>timeout</code></br>
<em>
<a href="https://godoc.org/k8s.io/apimachinery/pkg/apis/meta/v1#Duration">
Kubernetes meta/v1.Duration
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Time after which the build times out. Defaults to 10 minutes.
Specified build timeout should be less than 24h.
Refer Go&rsquo;s ParseDuration documentation for expected format: <a href="https://golang.org/pkg/time/#ParseDuration">https://golang.org/pkg/time/#ParseDuration</a></p>
</td>
</tr>
<tr>
<td>
<code>affinity</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#affinity-v1-core">
Kubernetes core/v1.Affinity
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>If specified, the pod&rsquo;s scheduling constraints</p>
</td>
</tr>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.BuildSpecStatus">
BuildSpecStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Used for cancelling a job (and maybe more later on)</p>
</td>
</tr>
</table>
</td>
</tr>
<tr>
<td>
<code>status</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.BuildStatus">
BuildStatus
</a>
</em>
</td>
<td>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.BuildTemplate">BuildTemplate
</h3>
<p>
<p>BuildTemplate is a template that can used to easily create Builds.</p>
</p>
<table>
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
build.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>BuildTemplate</code></td>
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
<a href="#build.knative.dev/v1alpha1.BuildTemplateSpec">
BuildTemplateSpec
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
<p>TODO(dprotaso) Metadata.Generation should increment so we
can drop this property when conversion webhooks enable us
to migrate</p>
</td>
</tr>
<tr>
<td>
<code>parameters</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.ParameterSpec">
[]ParameterSpec
</a>
</em>
</td>
<td>
<p>Parameters defines the parameters that can be populated in a template.</p>
</td>
</tr>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
[]Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<p>Steps are the steps of the build; each step is run sequentially with the
source mounted into /workspace.</p>
</td>
</tr>
<tr>
<td>
<code>volumes</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">
[]Kubernetes core/v1.Volume
</a>
</em>
</td>
<td>
<p>Volumes is a collection of volumes that are available to mount into the
steps of the build.</p>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.ClusterBuildTemplate">ClusterBuildTemplate
</h3>
<p>
<p>ClusterBuildTemplate is a template that can used to easily create Builds.</p>
</p>
<table>
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
build.knative.dev/v1alpha1
</code>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
string
</td>
<td><code>ClusterBuildTemplate</code></td>
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
<a href="#build.knative.dev/v1alpha1.BuildTemplateSpec">
BuildTemplateSpec
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
<p>TODO(dprotaso) Metadata.Generation should increment so we
can drop this property when conversion webhooks enable us
to migrate</p>
</td>
</tr>
<tr>
<td>
<code>parameters</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.ParameterSpec">
[]ParameterSpec
</a>
</em>
</td>
<td>
<p>Parameters defines the parameters that can be populated in a template.</p>
</td>
</tr>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
[]Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<p>Steps are the steps of the build; each step is run sequentially with the
source mounted into /workspace.</p>
</td>
</tr>
<tr>
<td>
<code>volumes</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">
[]Kubernetes core/v1.Volume
</a>
</em>
</td>
<td>
<p>Volumes is a collection of volumes that are available to mount into the
steps of the build.</p>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.ArgumentSpec">ArgumentSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.TemplateInstantiationSpec">TemplateInstantiationSpec</a>)
</p>
<p>
<p>ArgumentSpec defines the actual values to use to populate a template&rsquo;s
parameters.</p>
</p>
<table>
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
<p>Name is the name of the argument.</p>
</td>
</tr>
<tr>
<td>
<code>value</code></br>
<em>
string
</em>
</td>
<td>
<p>Value is the value of the argument.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.BuildProvider">BuildProvider
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildStatus">BuildStatus</a>)
</p>
<p>
<p>BuildProvider defines a build execution implementation.</p>
</p>
<h3 id="build.knative.dev/v1alpha1.BuildSpec">BuildSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.Build">Build</a>)
</p>
<p>
<p>BuildSpec is the spec for a Build resource.</p>
</p>
<table>
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
<p>TODO(dprotaso) Metadata.Generation should increment so we
can drop this property when conversion webhooks enable us
to migrate</p>
</td>
</tr>
<tr>
<td>
<code>source</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">
SourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Source specifies the input to the build.</p>
</td>
</tr>
<tr>
<td>
<code>sources</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">
[]SourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Sources specifies the inputs to the build.</p>
</td>
</tr>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
[]Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Steps are the steps of the build; each step is run sequentially with the
source mounted into /workspace.</p>
</td>
</tr>
<tr>
<td>
<code>volumes</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">
[]Kubernetes core/v1.Volume
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Volumes is a collection of volumes that are available to mount into the
steps of the build.</p>
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
<p>The name of the service account as which to run this build.</p>
</td>
</tr>
<tr>
<td>
<code>template</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.TemplateInstantiationSpec">
TemplateInstantiationSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Template, if specified, references a BuildTemplate resource to use to
populate fields in the build, and optional Arguments to pass to the
template. The default Kind of template is BuildTemplate</p>
</td>
</tr>
<tr>
<td>
<code>nodeSelector</code></br>
<em>
map[string]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>NodeSelector is a selector which must be true for the pod to fit on a node.
Selector which must match a node&rsquo;s labels for the pod to be scheduled on that node.
More info: <a href="https://kubernetes.io/docs/concepts/configuration/assign-pod-node/">https://kubernetes.io/docs/concepts/configuration/assign-pod-node/</a></p>
</td>
</tr>
<tr>
<td>
<code>timeout</code></br>
<em>
<a href="https://godoc.org/k8s.io/apimachinery/pkg/apis/meta/v1#Duration">
Kubernetes meta/v1.Duration
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Time after which the build times out. Defaults to 10 minutes.
Specified build timeout should be less than 24h.
Refer Go&rsquo;s ParseDuration documentation for expected format: <a href="https://golang.org/pkg/time/#ParseDuration">https://golang.org/pkg/time/#ParseDuration</a></p>
</td>
</tr>
<tr>
<td>
<code>affinity</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#affinity-v1-core">
Kubernetes core/v1.Affinity
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>If specified, the pod&rsquo;s scheduling constraints</p>
</td>
</tr>
<tr>
<td>
<code>Status</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.BuildSpecStatus">
BuildSpecStatus
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Used for cancelling a job (and maybe more later on)</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.BuildSpecStatus">BuildSpecStatus
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildSpec">BuildSpec</a>)
</p>
<p>
<p>BuildSpecStatus defines the build spec status the user can provide</p>
</p>
<h3 id="build.knative.dev/v1alpha1.BuildStatus">BuildStatus
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.Build">Build</a>)
</p>
<p>
<p>BuildStatus is the status for a Build resource</p>
</p>
<table>
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
</td>
</tr>
<tr>
<td>
<code>builder</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.BuildProvider">
BuildProvider
</a>
</em>
</td>
<td>
<em>(Optional)</em>
</td>
</tr>
<tr>
<td>
<code>cluster</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.ClusterSpec">
ClusterSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Cluster provides additional information if the builder is Cluster.</p>
</td>
</tr>
<tr>
<td>
<code>google</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.GoogleSpec">
GoogleSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Google provides additional information if the builder is Google.</p>
</td>
</tr>
<tr>
<td>
<code>startTime</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#time-v1-meta">
Kubernetes meta/v1.Time
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>StartTime is the time the build is actually started.</p>
</td>
</tr>
<tr>
<td>
<code>completionTime</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#time-v1-meta">
Kubernetes meta/v1.Time
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>CompletionTime is the time the build completed.</p>
</td>
</tr>
<tr>
<td>
<code>stepStates</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#containerstate-v1-core">
[]Kubernetes core/v1.ContainerState
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>StepStates describes the state of each build step container.</p>
</td>
</tr>
<tr>
<td>
<code>stepsCompleted</code></br>
<em>
[]string
</em>
</td>
<td>
<em>(Optional)</em>
<p>StepsCompleted lists the name of build steps completed.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.BuildTemplateInterface">BuildTemplateInterface
</h3>
<p>
<p>BuildTemplateInterface is implemented by BuildTemplate and ClusterBuildTemplate</p>
</p>
<h3 id="build.knative.dev/v1alpha1.BuildTemplateSpec">BuildTemplateSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildTemplate">BuildTemplate</a>, 
<a href="#build.knative.dev/v1alpha1.ClusterBuildTemplate">ClusterBuildTemplate</a>)
</p>
<p>
<p>BuildTemplateSpec is the spec for a BuildTemplate.</p>
</p>
<table>
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
<p>TODO(dprotaso) Metadata.Generation should increment so we
can drop this property when conversion webhooks enable us
to migrate</p>
</td>
</tr>
<tr>
<td>
<code>parameters</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.ParameterSpec">
[]ParameterSpec
</a>
</em>
</td>
<td>
<p>Parameters defines the parameters that can be populated in a template.</p>
</td>
</tr>
<tr>
<td>
<code>steps</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
[]Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<p>Steps are the steps of the build; each step is run sequentially with the
source mounted into /workspace.</p>
</td>
</tr>
<tr>
<td>
<code>volumes</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#volume-v1-core">
[]Kubernetes core/v1.Volume
</a>
</em>
</td>
<td>
<p>Volumes is a collection of volumes that are available to mount into the
steps of the build.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.ClusterSpec">ClusterSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildStatus">BuildStatus</a>)
</p>
<p>
<p>ClusterSpec provides information about the on-cluster build, if applicable.</p>
</p>
<table>
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
<p>Namespace is the namespace in which the pod is running.</p>
</td>
</tr>
<tr>
<td>
<code>podName</code></br>
<em>
string
</em>
</td>
<td>
<p>PodName is the name of the pod responsible for executing this build&rsquo;s steps.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.GCSSourceSpec">GCSSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">SourceSpec</a>)
</p>
<p>
<p>GCSSourceSpec describes source input to the Build in the form of an archive,
or a source manifest describing files to fetch.</p>
</p>
<table>
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
<a href="#build.knative.dev/v1alpha1.GCSSourceType">
GCSSourceType
</a>
</em>
</td>
<td>
<p>Type declares the style of source to fetch.</p>
</td>
</tr>
<tr>
<td>
<code>location</code></br>
<em>
string
</em>
</td>
<td>
<p>Location specifies the location of the source archive or manifest file.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.GCSSourceType">GCSSourceType
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.GCSSourceSpec">GCSSourceSpec</a>)
</p>
<p>
<p>GCSSourceType defines a type of GCS source fetch.</p>
</p>
<h3 id="build.knative.dev/v1alpha1.GitSourceSpec">GitSourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.SourceSpec">SourceSpec</a>)
</p>
<p>
<p>GitSourceSpec describes a Git repo source input to the Build.</p>
</p>
<table>
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
string
</em>
</td>
<td>
<p>URL of the Git repository to clone from.</p>
</td>
</tr>
<tr>
<td>
<code>revision</code></br>
<em>
string
</em>
</td>
<td>
<p>Git revision (branch, tag, commit SHA or ref) to clone.  See
<a href="https://git-scm.com/docs/gitrevisions#_specifying_revisions">https://git-scm.com/docs/gitrevisions#_specifying_revisions</a> for more
information.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.GoogleSpec">GoogleSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildStatus">BuildStatus</a>)
</p>
<p>
<p>GoogleSpec provides information about the GCB build, if applicable.</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>operation</code></br>
<em>
string
</em>
</td>
<td>
<p>Operation is the unique name of the GCB API Operation for the build.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.ParameterSpec">ParameterSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildTemplateSpec">BuildTemplateSpec</a>)
</p>
<p>
<p>ParameterSpec defines the possible parameters that can be populated in a
template.</p>
</p>
<table>
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
<p>Name is the unique name of this template parameter.</p>
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
<p>Description is a human-readable explanation of this template parameter.</p>
</td>
</tr>
<tr>
<td>
<code>default</code></br>
<em>
string
</em>
</td>
<td>
<p>Default, if specified, defines the default value that should be applied if
the build does not specify the value for this parameter.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.SourceSpec">SourceSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildSpec">BuildSpec</a>)
</p>
<p>
<p>SourceSpec defines the input to the Build</p>
</p>
<table>
<thead>
<tr>
<th>Field</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<code>git</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.GitSourceSpec">
GitSourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Git represents source in a Git repository.</p>
</td>
</tr>
<tr>
<td>
<code>gcs</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.GCSSourceSpec">
GCSSourceSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>GCS represents source in Google Cloud Storage.</p>
</td>
</tr>
<tr>
<td>
<code>custom</code></br>
<em>
<a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core">
Kubernetes core/v1.Container
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Custom indicates that source should be retrieved using a custom
process defined in a container invocation.</p>
</td>
</tr>
<tr>
<td>
<code>subPath</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>SubPath specifies a path within the fetched source which should be
built. This option makes parent directories <em>inaccessible</em> to the
build steps. (The specific source type may, in fact, not even fetch
files not in the SubPath.)</p>
</td>
</tr>
<tr>
<td>
<code>name</code></br>
<em>
string
</em>
</td>
<td>
<em>(Optional)</em>
<p>Name is the name of source. This field is used to uniquely identify the
source init containers
Restrictions on the allowed charatcers
Must be a basename (no /)
Must be a valid DNS name (only alphanumeric characters, no _)
<a href="https://tools.ietf.org/html/rfc1123#section-2">https://tools.ietf.org/html/rfc1123#section-2</a></p>
</td>
</tr>
<tr>
<td>
<code>targetPath</code></br>
<em>
string
</em>
</td>
<td>
<p>TargetPath is the path in workspace directory where the source will be copied.
TargetPath is optional and if its not set source will be copied under workspace.
TargetPath should not be set for custom source.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.Template">Template
</h3>
<p>
<p>Template is an interface for accessing the BuildTemplateSpec
from various forms of template (namespace-/cluster-scoped).</p>
</p>
<h3 id="build.knative.dev/v1alpha1.TemplateInstantiationSpec">TemplateInstantiationSpec
</h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.BuildSpec">BuildSpec</a>)
</p>
<p>
<p>TemplateInstantiationSpec specifies how a BuildTemplate is instantiated into
a Build.</p>
</p>
<table>
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
<p>Name references the BuildTemplate resource to use.
The template is assumed to exist in the Build&rsquo;s namespace.</p>
</td>
</tr>
<tr>
<td>
<code>kind</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.TemplateKind">
TemplateKind
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>The Kind of the template to be used, possible values are BuildTemplate
or ClusterBuildTemplate. If nothing is specified, the default if is BuildTemplate</p>
</td>
</tr>
<tr>
<td>
<code>arguments</code></br>
<em>
<a href="#build.knative.dev/v1alpha1.ArgumentSpec">
[]ArgumentSpec
</a>
</em>
</td>
<td>
<em>(Optional)</em>
<p>Arguments, if specified, lists values that should be applied to the
parameters specified by the template.</p>
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
<p>Env, if specified will provide variables to all build template steps.
This will override any of the template&rsquo;s steps environment variables.</p>
</td>
</tr>
</tbody>
</table>
<h3 id="build.knative.dev/v1alpha1.TemplateKind">TemplateKind
(<code>string</code> alias)</p></h3>
<p>
(<em>Appears on:</em>
<a href="#build.knative.dev/v1alpha1.TemplateInstantiationSpec">TemplateInstantiationSpec</a>)
</p>
<p>
<p>TemplateKind defines the type of BuildTemplate used by the build.</p>
</p>
<hr/>
<p><em>
Generated with <code>gen-crd-api-reference-docs</code>
on git commit <code>0ff65541</code>.
</em></p>
