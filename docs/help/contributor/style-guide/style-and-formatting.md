# Formatting standards and conventions

## Titles and headings

### Use sentence case for titles and headings

> Only capitalize proper nouns, acronyms, and the first word of the heading.

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

> For consistency, brevity, and to better signpost where action is expected of the reader, make procedure headings imperatives.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|----------------------|-----
|## Install Knative Serving            | ## Installation of Knative Serving
|### Configure DNS          | ### Configuring DNS
|## Verify the installation                   | ## How to verify the installation

## Links

### Make links descriptive

|:white_check_mark: Correct                                     |:no_entry: Incorrect
|---------------------------------------|------
|For an explanation of what makes a good hyperlink, see this [this article](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021).| See this article [here](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021).

<!-- Add rule here, see https://github.com/knative/docs/issues/4034 -->

## Formatting

### Use nonbreaking spaces in units of measurement other than percent

> For most units of measurement, when you specify a number with the unit, use a nonbreaking space
between the number and the unit.

> Don't use spacing when the unit of measurement is percent.

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

## General style

### Use upper camel case for Knative API objects

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Channels | channels
|Broker      | broker
|ContainerSource | Container Source

### Only use parentheses for acronym explanations

>Put an acronym inside parentheses after its explanation. Don’t use parentheses for anything else.

>Parenthetical statements especially should be avoided because readers skip them.
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
