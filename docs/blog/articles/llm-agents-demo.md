# LLM Agents with Knative: A Demo

**Author: [Calum Murray](https://www.linkedin.com/in/calum-ra-murray/), Software Engineering Intern @ Red Hat**

In the [previous blog post on LLM Agents](/blog/articles/llm-agents-overview)
we discussed what LLM Agents are, how LLMs call tools, and how Knative can
be used to automate the tool calling process for LLM Agents. In this blog post
we will be looking at a concrete example of how you can build an LLM Agent
application with Knative handling the tool calling and discovery, and explaining
what differentiates this approach from the other common approaches for building
LLM Agents.

## An example LLM Agent using Knative

To showcase the power of building LLM Agents with the tool discovery and
calling handled by Knative, we are going to build a simple chat application
that is capable of answering questions about the cost of resources being
used for a fictitious application we are running. Specifically, in our
application we are interested in accurately answering questions such as:

> How has the trend in the average resource consumption (CPU, memory)
changed over the past few months for my application, and what impact
will this have on my costs?

To begin, we will be deploying the Knative LLM Tool Provider demo into
a cluster we have access to following the instructions in the README in
[https://github.com/keventmesh/llm-tool-provider](https://github.com/keventmesh/llm-tool-provider). 
Once we have deployed the chat app from this repository, we are able to access it by running:

```bash
kubectl port-forward svc/chat-app-service 8080:8080
```

If you access `http://localhost:8080` in your browser you will now be able
to see the chat application running, and ask it our simple question. When
I tried this while writing the blog post, the interaction was:

Calum:
> How has the trend in the average resource consumption (CPU, memory)
changed over the past few months for my application, and what impact
will this have on my costs?

LLM Agent:
> Could you provide me with the data on the average resource consumption
(CPU, GPU, memory) for your application over the past few months?

If you try this you will likely notice that your LLM agent replies similarly,
and that the UI will indicate in the task list a task called “human”. This is
the LLM calling the one hand-coded tool that we have in our sample app: a tool
that asks the user (the human) for more information before continuing to answer
the question.

From this interaction, we can see that the LLM isn’t capable of answering our
question yet: it has no information about the resource consumption or about
what the costs associated with that resource consumption are. To give the LLM
these capabilities we need to tell it about the two Knative Functions we
deployed into our cluster in the setup of the sample app:
`average-resource-consumption` and `resource-cost-calculator`. To do this
we will need to apply two EventTypes into our cluster which describe the
contracts expected by these Functions:

```yaml
apiVersion: eventing.knative.dev/v1beta2
kind: EventType
metadata:
  name: average.resource.consumption
spec:
  reference:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: average-resource-consumption
  description: "This tells you the average resource consumption for recent months"
  type: "average.resource.consumption"
---
apiVersion: eventing.knative.dev/v1beta2
kind: EventType
metadata:
  name: resource.cost.calculator
spec:
  reference:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: resource-cost-calculator
  description: "This calculates the cost for a given resource kind and average usage over a month. Use this tool whenever there is a question about the cost of any cloud resources"
  schemaData: '{"resourceKind":{"type":"string","description":"The type of resource you would like to calculate the cost of"},"usage":{"type":"float","description":"The average usage of the resource"},"unit":{"type":"string","description":"The unit of the resource usage"}}'
  type: "resource.cost.calculator"
```

Both of these EventTypes refer to functions which were deployed in the install
script we ran earlier. One function returns some mock usage data for the past
few months, and the other is able to calculate the cost due to the usage of a
specific resource type for a specific month.

The LLM Agents we built is programmed to fetch all the EventTypes in the cluster
whenever a new user session starts, and map those into tools it can use. After
applying both EventTypes and refreshing our brower, we can try asking our original
question again:

Calum:
> How has the trend in the average resource consumption (CPU, memory) changed
over the past few months for my application, and what impact will this have on
my costs?

LLM Agent:
> The trend in the average resource consumption for your application over the
past few months is as follows:

> - March: CPU - 21.33 Cores, Memory - 8200 MiB
> - April: CPU - 27.56 Cores, Memory - 8117 MiB
> - May: CPU - 33.17 Cores, Memory - 9217 MiB
> - June: CPU - 34.51 Cores, Memory - 10117 MiB

> To determine the impact on your costs, I will calculate the cost for CPU and
memory based on the average usage over a month for each resource. Let's proceed
with the cost calculation.The estimated impact on your costs based on the average
resource consumption for your application over the past few months is as follows:

> - CPU cost: $448.28
> - Memory cost: $161.87

> These costs are calculated based on the average monthly usage of CPU and memory
resources. If you have any more questions or need further assistance, feel free
to ask!

Looking into the tools window, we can see that the LLM called both of the tools
we provided to it, and the answer is evidently higher quality and more accurate!

What is truly powerful about what we just did was not that the LLM was able to
use tools to more accurately reply to the user, it was that the LLM was able to
use tools to more accurately reply to the user _without us re-deploying the LLM
application_. We have decoupled the development and deployment of the tools from
the development and deployment of the LLM agent! 

Now, we are able to declaratively bind these two components together through a
glue of EventTypes, but the people building our LLM agent do not need to worry
about what tools it will have access to or how it will call them, and the teams
making tools can give it access to their tools without learning the codebase for
the LLM agent. Furthermore, since all we did was provide metadata about a service
to the LLM we can now create EventTypes to describe existing services we have
already built, and the LLM agent will be able to successfully interact with those
systems with _no code changes_.

This concept of automatic tool discovery by an LLM Agent through the use of
metadata is the central concept to what we are working to build. In the next
blog post we will discuss our vision for how this will evolve. If you are
interested in helping us build the future of LLM Agents in the cloud, message
us on the [CNCF slack instance](https://slack.cncf.io)!
