# My LFX Mentorship Experience: Enhancing the Knative func CLI Experience

**Author: [Rayyan Seliya](https://www.linkedin.com/in/rayyan-seliya/){:target="_blank"}, LFX'25 Mentee**

Over the past three months, I've had the incredible opportunity to participate in the LFX Mentorship Program. My specific project was titled [CNCF - Knative: Enhancing the Knative func CLI Experience](https://github.com/knative/ux/issues/196){:target="_blank"}. As the term wraps up, I want to take a moment to reflect on my journey and share it with you.

## Project Overview

Knative Functions enables developers to easily create, build, and deploy stateless, event driven functions as Knative Services by using the `func` CLI. The goal of this LFX project was to conduct a comprehensive UX evaluation of the func CLI, focusing on identifying usability issues, understanding developer workflows, and gathering structured feedback on CLI interactions to improve its intuitiveness, efficiency, and user satisfaction.

While the project covered several areas like assessing command organization and discoverability, my main focus was specifically on improving error handling and help text quality throughout the codebase. The core philosophy behind my work was simple: error messages should not just state what went wrong, but guide users toward the solution with clear, actionable steps. To gather comprehensive error reports, I tested all the commands with valid inputs to verify expected behavior, invalid inputs to test error handling, and edge cases like empty strings, special characters, and boundary values. I also tested flag combinations, environment variable interactions, and intentionally violated validation rules to see how the CLI responded. This approach helped me understand the error quality and identify where users would struggle the most. Rather than just producing a report with recommendations, I also worked on actively fixing the issues I discovered.

## Understanding the User Perspective

To better understand the challenges users face, I reached out to my peers in college to learn about their initial experience with Knative Functions. Their responses revealed a common pattern. Most people would start by reading the [func README](https://github.com/knative/func/blob/main/README.md){:target="_blank"}, then head to the [Knative documentation website](https://knative.dev/docs/functions/){:target="_blank"} for functions. The installation usually went smoothly without any issues. But then came what I found most fascinating: the curiosity phase.

After installation, most people, including myself when I first started, would simply type commands like `func deploy`, `func build`, or `func invoke` just to see what happens. We were curious, exploring, trying to understand what each command does. But the problem was what they encountered. Error messages like this:

```
Error: '/mnt/c/Users/RAYYAN/Desktop/func' does not contain an initialized function
```

Technically correct, but not very helpful if you're just starting out. What should you do next? Where do you even begin?

## Improving Help Text

My initial weeks focused on improving the help text for all commands when run outside a function directory. I wanted to make those cryptic error messages actually helpful. 

Here's how that same error I mentioned above looks now with the new help text:

```
Error: no function found in current directory.

You need to be inside a function directory to invoke it.

Try this:
  func create --language go myfunction    Create a new function
  cd myfunction                          Go into the function directory
  func invoke                            Now you can invoke it

Or if you have an existing function:
  cd path/to/your/function              Go to your function directory
  func invoke                           Invoke the function
```

See the difference? Instead of just stating the problem, the message now guides you toward the solution with clear, actionable steps.

## A Systematic Approach

Around week 3, I had an important discussion with [Luke Kingland](https://github.com/lkingland){:target="_blank"} and [David Friedrich](https://github.com/gauron99){:target="_blank"}, maintainers of the func project. They provided valuable feedback that changed how I approached the problem. Instead of handling errors randomly in the CLI layer, we decided to implement a two-layer architecture.

The approach was straightforward: first, define error types in [`errors.go`](https://github.com/knative/func/blob/main/pkg/functions/errors.go){:target="_blank"}, then catch these errors in the CLI layer and provide user friendly, educational messages. This systematic approach meant that errors would be consistently handled throughout the codebase, and we could provide helpful context at exactly the right moment.

## Systematic Testing and Documentation

As I continued making improvements, my mentor [Calum Murray](https://www.linkedin.com/in/calum-ra-murray/){:target="_blank"} suggested something that would define the rest of my mentorship: create comprehensive error reports for each command rather than randomly fixing issues as I found them. This suggestion changed everything.

I began systematically testing and documenting every command from multiple perspectives. I tested as a complete beginner encountering the CLI for the first time, as a maintainer who needs to debug issues, and as a professional developer using advanced features. I tested valid inputs, invalid inputs, edge cases, special characters, boundary values, flag combinations, and environment variables. Essentially, everything I could think of.

The result was comprehensive error reports for 12 core commands, including `func deploy`, `func build`, `func run`, `func create`, `func subscribe`, `func invoke`, `func describe`, `func list`, `func environment`, `func repository`, `func delete`, and `func config`. Each command got its own detailed Google Doc and GitHub issue. To track everything in one place, I created a [central hub issue](https://github.com/knative/func/issues/3236){:target="_blank"} that documents over 200+ issues across all these commands.

## Patterns and Insights

As I worked through these commands, interesting patterns started to emerge. Many commands shared similar problems. Some would start lengthy operations like building containers before validating basic inputs like registry names or namespaces, which wasted time and confused users. 

Other commands would crash with application panics instead of showing graceful error messages. There were also silent failures where operations that should have failed would succeed without any indication, leaving users puzzled. And then there were the technical error messages that exposed internal implementation details instead of helping users understand what to do next.

Identifying these patterns was incredibly valuable. It helped me fix issues more systematically and ensure consistency across the entire CLI.

## Program Experience

I still remember exploring the func CLI for the first time before applying to the program and barely understanding what each command was supposed to do. Now with comprehensive error reports documented for 12 commands, this mentorship experience has been incredibly insightful.

One of the standout aspects of this program was the ample opportunities I had to engage with the Knative Functions community. Initially, I was hesitant to propose changes to error messages, worried that my approach might not align with the project's vision. However, as I started participating in discussions more and noticed how supportive the maintainers were, I gained much more confidence. The community embraced this user centered approach, and I developed a deeper appreciation for the collaborative nature of open source.

The experience was not without technical challenges. One major challenge was ensuring consistency across all commands while respecting the existing architecture. For example, implementing the two-layer error handling approach required understanding how errors flowed through the codebase and ensuring all parts calling these functions still operated correctly. 

Testing every edge case, documenting patterns across commands, and mapping developer workflows was initially overwhelming. Understanding the architectural design and how different commands interacted took time, but it was an invaluable learning process that enhanced my problem solving skills and technical knowledge.

By the end of the program, I had achieved significant milestones: I opened [17 issues](https://github.com/knative/func/issues?q=is%3Aissue+author%3ARayyanSeliya){:target="_blank"} and merged [17 PRs](https://github.com/knative/func/pulls?q=is%3Apr+author%3ARayyanSeliya+is%3Amerged){:target="_blank"}. For someone who started with limited understanding of the func CLI, these accomplishments are particularly meaningful for me.

## Final Comments

I would like to extend my gratitude to my mentors [Calum Murray](https://www.linkedin.com/in/calum-ra-murray/){:target="_blank"} and [Prajjwal Yadav](https://www.linkedin.com/in/prajjwalyd/){:target="_blank"} for their guidance throughout this project. Your mentorship helped me approach this project systematically and effectively. I'm also deeply grateful to the PR review team, [Luke Kingland](https://github.com/lkingland){:target="_blank"}, [David Friedrich](https://github.com/gauron99){:target="_blank"}, and [Matej Vašek](https://github.com/matejvasek){:target="_blank"}, for reviewing my contributions and helping me refine my approach.

In a few years, I might not remember every line of code I wrote or every error message I improved, but I will always remember the satisfaction of transforming cryptic errors into helpful guidance. This experience has shown me that sometimes the most impactful improvements are the ones that help users when things go wrong. I'm excited to continue contributing to Knative and making developer tools that don't just work, but teach and guide along the way.

## A Tip for Future LFX Applicants

If you've read this far, I'd like to share something that might help you with your own LFX journey. The key to my acceptance was starting early and engaging with the community before even applying. I reached out to my mentors as soon as the projects were announced and asked how I could better prepare myself. Their advice was invaluable: play around with the func CLI to get familiar with it, write the research proposal myself without relying on AI tools, think deeply about the research objectives and questions I wanted to answer, plan out how I would approach answering those questions, and create a realistic timeline for the project.

So I did exactly that. I explored all the func commands, experimented with different scenarios, and even got two PRs merged before submitting my proposal. When it came time to write the proposal, I documented this pre-engagement experience in detail, including the issues I discovered and improvements I suggested. I went a step further and created a demo showing how the func CLI could have colorful output following industry best practices from tools like `kubectl`, `git`, and `aws` cli.

The lesson I learned is that both pre-community engagement and a well-prepared proposal are equally important. Show genuine interest, contribute early, and then document your journey and approach thoroughly in your proposal. If you're curious about how I structured all of this, you can check out my [proposal here](https://www.canva.com/design/DAGk0QzPceA/TuwOj83JbUnd_b-nnTh9MQ/view?utm_content=DAGk0QzPceA&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=h3c4ce65cb5){:target="_blank"}, which also includes the demo I created. Good luck with your open source journey!
