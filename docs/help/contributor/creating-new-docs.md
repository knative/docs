# Creating new documentation

To contribute new documentation, follow these steps:

1. Identify the audience and intended use for the information.
1. Choose the [type of content](#content-types) you wish to contribute.
<!-- Add "Choose a template" step with links to all the templates. -->
1. [Choose appropriate titles and filenames](#choosing-titles-and-filenames).
1. Write your new content. See the style guide to help you with this process.
   Feel free to reach out to the
   [Docs Working Group](/becoming-a-contributor.md#get-help-from-the-community) with any questions.
1. Open a PR in the [knative/docs GitHub repository](https://github.com/knative/docs)
   to kick off the review process. For details, see our
   [Using GitHub help](/github.md#prs).

## Identify the audience and intended use

The best documentation starts by knowing the intended readers, their knowledge,
and what you expect them to do with the information. Otherwise, you cannot
determine the appropriate scope and depth of information to provide, its ideal
structure, or the necessary supporting information. The following examples show
this principle in action:

- The reader needs to perform a specific task. Tell them how to recognize when
  the task is necessary, and provide the task itself as a list of numbered steps. Don’t simply describe the task in general terms.

- The reader must understand a concept before they can perform a task: Before
  the task, tell them about the prerequisite information and provide a link to
  it.

- The reader needs to make a decision: Provide the conceptual information
  necessary to know when to make the decision, the available options, and when
  to choose one option instead of the other.

- The reader is an administrator but not a SWE: Provide a script,
  not a link to a code sample in a developer’s guide.

- The reader needs to extend the features of the product: Provide an example of
  how to extend the feature, using a simplified scenario for illustration
  purposes.

- The reader needs to understand complex feature relationships: Provide a
  diagram showing the relationships, rather than writing multiple pages of
  content that is tedious to read and understand.

The most important thing to avoid is the common mistake of simply
giving readers all the information you have, because you are unsure about
what information they need.

If you need help identifying the audience for you content, we are happy to help
and answer all your questions during the [DUX](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
weekly meetings.

## Content types

When you understand the audience and the intended use for the information you
provide, you can choose content type that best addresses their needs. To make it
easy for you to choose, the following table shows the supported content types,
their intended audiences, and the goals each type strives to achieve:

<table>
    <thead>
        <tr>
            <th>Content type</th>
            <th>Goals</th>
            <th>Audiences</th>
        </tr>
    </thead>
    <tr>
      <td>Concept</td>
      <td>Explain some significant aspect of Knative. For example, a concept page
      describes the configuration model of a feature and explains its functionality.
      Concept pages don't include sequences of steps. Instead, provide links to
      corresponding tasks.</td>
      <td>Readers that want to understand how features work with only basic
      knowledge of the project.</td>
    </tr>
    <tr>
      <td>Reference</td>
      <td>Provide exhaustive and detailed technical information. Common examples
      include API parameters, command-line options, configuration settings, and
      advanced procedures. Reference content is generated from the Knative code
      base and tested for accuracy.
      </td>
      <td>Readers with advanced and deep technical knowledge of the project that
      needs specific bits of information to complete advanced tasks.</td>
    </tr>
    <tr>
      <td>Example</td>
      <td>Describe a working and stand-alone example that highlights a set of
      features, an integration of Knative with other projects, or an end-to-end
      solution for a use case. Examples must use an existing Knative setup as a
      starting point. Examples must include an automated test since they are maintained for technical accuracy.
      </td>
      <td>Readers that want to quickly run the example themselves and
      experiment. Ideally, readers should be able to easily change the example
      to produce their own solutions.</td>
    </tr>
    <tr>
      <td>Procedure</td>
      <td>Shows how to achieve a single goal using Knative features. Procedures are written
      as a sequence of steps. Procedures provide minimal
      explanation of the features, but include links to the concepts that
      provide the related background and knowledge. Procedures must include automated
      tests since they are tested and maintained for technical accuracy.</td>
      <td>Readers that want to use Knative features.</td>
    </tr>
    <tr>
      <td>Setup</td>
      <td>Focus on the installation steps needed to complete an Knative
      deployment. Setup pages must include automated tests since they are tested and maintained for technical accuracy.
      </td>
      <td>New and existing Knative users that want to complete a deployment.</td>
    </tr>
    <tr>
      <td>Blog</td>
      <td>
        Focus on Knative or products and technologies related to it. Blog posts fall in one of the following three categories:
        <ul>
        <li>Posts detailing the author’s experience using and configuring Knative, especially those that articulate a novel experience or perspective.</li>
        <li>Posts highlighting Knative features.</li>
        <li>Posts detailing how to accomplish a task or fulfill a specific use case using Knative. Unlike Tasks and Examples, the technical accuracy of blog posts is not maintained and tested after publication.</li>
        </ul>
      </td>
      <td>Readers with a basic understanding of the project who want to learn
      about it in an anecdotal, experiential, and more informal way.</td>
    </tr>
    <tr>
      <td>News</td>
      <td>
        Focus on timely information about Knative and related events. News entries typically announce new releases or upcoming events.
      </td>
      <td>Readers that want to quickly learn what's new and what's happening in
      the Knative community.</td>
    </tr>
    <tr>
      <td>FAQ</td>
      <td>
        Provide quick answers to common questions. Answers don't introduce any
        concepts. Instead, they provide practical advice or insights. Answers
        must link to tasks, concepts, or examples in the documentation for readers to learn more.
      </td>
      <td>Readers with specific questions who are looking for brief answers and
      resources to learn more.</td>
    </tr>
    <tr>
      <td>Operation guide</td>
      <td>
        Focus on practical solutions that address specific problems encountered while running Knative in a real-world setting.
      </td>
      <td>Service mesh operators that want to fix problems or implement
      solutions for running Knative deployments.</td>
    </tr>
  </table>

## Choosing titles and filenames

Choose a title for your new content, either a new page title or a title for
a section that you want to add. Make sure it includes the keywords you want
search engines to find and use sentence style capitalization.

#### New files

The filename of your new content should reflect the title.

#### New files and folders

If the content that you add include a new folder, name that folder using
the keywords that cover the scope of the content in the folder, separated by
hyphens, all in lowercase. Keep folder names as short as possible to make
cross-references easier to create and maintain. You should only need to create
a new folder if you are adding multiple topics/files, or if you are grouping
related content. The names for each file do not need to repeat the folder name
since that context is already established.

## Submit your contribution to GitHub

If you are not familiar with GitHub, see our [working with GitHub guide](/github.md)
to learn how to submit documentation changes.
