# Formatting standard and conventions

## Documenting Knative API Objects
>  Use title case for Knative API objects.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Channels | channels
|Broker      | broker


## Using parentheses
>Don’t use parentheses, unless it’s the first instance in a page to explain an acronym that isn’t immediately obvious.

>Parenthetical statements especially should be avoided because if something is important enough to be in the sentence, it should be fully part of that sentence.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Install the Custom Resource Definition (CRD) | Check your CLI (you should see it there)
|Knative Serving will create a Revision      | Knative will create a Revision (a stateless, snapshot in time of your code and configuration)


## Use sentence case for titles and headings

> Use sentence case for all titles and headings. Only capitalize the first
word of the heading, except for proper nouns or acronyms.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|--------------------|-----
|Configuring feature | Configuring Feature
|Using feature      | Using Feature
|Using HTTPS         | Using https

## Create descriptive links

|:white_check_mark: Correct                                     |:no_entry: Incorrect
|---------------------------------------|------
|Check out [this excellent article](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021) explaining <br> what makes a good hyperlink    | Check out the article [here](https://medium.com/@heyoka/Correctnt-use-click-here-f32f445d1021)

## Use spaces in units of measurement

> For most units of measurement, when you specify a number with the unit, use a nonbreaking space
between the number and the unit.

> Don't use spacing when the unit of measurement is percent.

|:white_check_mark: Correct                  |:no_entry: Incorrect
|----------------------|-----
|3`&nbsp`GB            | 3 GB
|4`&nbsp`CPUs          | 4 CPUs
|14%                   | 14`&nbsp`%
