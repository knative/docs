# Formatting standards and conventions

## Titles and headings

### Use sentence case for titles and headings

Only capitalize proper nouns, acronyms, and the first word of the heading.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|## Configure the feature | ## Configure the Feature
|### Using feature      | ### Using Feature
|### Using HTTPS         | ### Using https

### Do not use code formatting inside headings

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|## Configure the class annotation | ## Configure the \`class\` annotation

### Use imperatives for headings of procedures

For consistency, brevity, and to better signpost where action is expected of the reader, make procedure headings imperatives.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|----------------------|-----
|## Install Knative Serving            | ## Installation of Knative Serving
|### Configure DNS          | ### Configuring DNS
|## Verify the installation                   | ## How to verify the installation

## Links

### Describe what the link targets

|:white_check_mark: Correct                                     |:no_entry: Incorrect
|---------------------------------------|------
|For an explanation of what makes a good hyperlink, see this [this article](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021).| See this article [here](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021).

### Write links in Markdown, not HTML

|:white_check_mark: Correct                                     |:no_entry: Incorrect|
|---------------------------------------|------|
|`[Kafka Broker](../kafka-broker/README.md)`|`<a href="../kafka-broker/README.md">Kafka Broker</a>`|
|`[Kafka Broker](../kafka-broker/README.md){target=_blank}`|`<a href="../kafka-broker/README.md" target="_blank">Kafka Broker</a>`|

### Include the .md extension in internal links

|:white_check_mark: Correct                                     |:no_entry: Incorrect|
|---------------------------------------|------|
|`[Setting up a custom domain](../serving/using-a-custom-domain.md)`|`[Setting up a custom domain](../serving/using-a-custom-domain)`|

### Link to files, not folders

|:white_check_mark: Correct                                     |:no_entry: Incorrect|
|---------------------------------------|------|
|`[Kafka Broker](../kafka-broker/README.md)`|`[Kafka Broker](../kafka-broker/)`|

### Ensure the letter case is correct

|:white_check_mark: Correct                                     |:no_entry: Incorrect|
|---------------------------------------|------|
|`[Kafka Broker](../kafka-broker/README.md)`|`[Kafka Broker](../kafka-broker/readme.md)`|

## Formatting

### Use nonbreaking spaces in units of measurement other than percent

For most units of measurement, when you specify a number with the unit, use a nonbreaking space
between the number and the unit.

Don't use spacing when the unit of measurement is percent.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|----------------------|-----
|3`&nbsp`GB            | 3 GB
|4`&nbsp`CPUs          | 4 CPUs
|14%                   | 14`&nbsp`%

### Use bold for user interface elements

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Click **Fork** | Click "Fork"
|Select **Other**      | Select "Other"

### Use tables for definition lists

When listing terms and their definitions, use table formatting instead of definition list formatting.

:white_check_mark: **Correct**

```
| Value  | Description           |
|--------|-----------------------|
| Value1 | Description of Value1 |
| Value2 | Description of Value2 |
```

:no_entry: **Incorrect**

```
**Value1:**
Description of Value1

**Value2:**
Description of Value2
```

## General style

### Use upper camel case for Knative API objects

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Channels | channels
|Broker      | broker
|ContainerSource | Container Source

### Only use parentheses for acronym explanations

Put an acronym inside parentheses after its explanation. Don’t use parentheses for anything else.

Parenthetical statements especially should be avoided because readers skip them.
If something is important enough to be in the sentence, it should be fully part of that sentence.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Custom Resource Definition (CRD) |Check your CLI (you should see it there)
|Knative Serving creates a Revision |Knative creates a Revision (a stateless, snapshot in time of your code and configuration)|

### Use the international standard for punctuation inside quotes

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Events are recorded with an associated "stage". | Events are recorded with an associated "stage."
|The copy is called a "fork".      | The copy is called a "fork."
