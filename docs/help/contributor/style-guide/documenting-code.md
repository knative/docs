# Documenting Code

??? tip "Looking for a template?"
    //todo

## Words requiring code formatting
Use code formatting to indicate special purpose text. Apply code formatting to the following content:

* Filenames and path names
* Any text that goes into a CLI

## Specify the programming language

> Be sure to specify the language your code is in as part of the code block

> Specify non-language specific code, like CLI commands, specify ```bash (see below for formatting).

=== ":white_check_mark: Correct"
    ```go
    package main

    import "fmt"

    func main() {
        fmt.Println("hello world")
    }
    ```

=== ":no_entry: Incorrect"
    ```bash
    package main

    import "fmt"

    func main() {
        fmt.Println("hello world")
    }
    ```

=== ":white_check_mark: Correct Formatting"
    ````
    ```go
    package main

    import "fmt"

    func main() {
        fmt.Println("hello world")
    }
    ```
    ````
=== ":no_entry: Incorrect Formatting"
    ````
    ```bash
    package main

    import "fmt"

    func main() {
        fmt.Println("hello world")
    }
    ```
    ````

## Documenting commands

>**The standard line is “X the Y by running the command:”**

>It meets these criteria:

>* Explicitly mentions running the command (this isn’t always obvious)
* **Uses “run”** (and not “type”, “execute”, etc -- we want consistency)
* Starts with the key information that describes the command, e.g. “To do X...run Y command:”, “Do X by running Y command:”
* As short as possible

> If you must deviate from the standard line, ensure you still meet the above criteria.

=== ":white_check_mark: Correct"
    Create the service by running the command:
    ```bash
    kn create service <service-name>
    ```
    Where `<service-name>` is the name of your Knative Service.

=== ":no_entry: Incorrect"
    **Example 1:**

    Create the service:
    ```bash
    kn create service <service-name>
    ```
    Where `<service-name>` is the name of your Knative Service.

    **Example 2:**

    Run:
    ```bash
    kn create service <service-name>
    ```
    Where `<service-name>` is the name of your Knative Service.

    **Example 3:**

    Run the command below to create a service:

    ```bash
    kn create service <service-name>
    ```
    Where `<service-name>` is the name of your Knative Service.

## Documenting YAML
//TODO CONTENT TABS (ex. kn + YAML)
>When documenting YAML, use two steps. Use step 1 to create the YAML file, and step 2 to apply the YAML file.

>Use **kubectl apply** for files/objects that the user creates — it works for both “create” and “update”, and the source of truth is their local files.

>Use **kubectl edit** for files which are shipped as part of the Knative software, like the serving/eventing ConfigMaps.

> be sure to use ```yaml at the beginning of your code block if you are typing YAML code as part of a CLI command

=== ":white_check_mark: Correct"

    - Creating or updating a resource:

        1. Create a YAML file using the template below:

            ```yaml
            # YAML FILE CONTENTS
            ```
        2. Apply the YAML file by running:

            ```bash
            kubectl apply --filename <filename>.yaml
            ```

    - Editing a ConfigMap:

        ```bash
        kubectl -n <namespace> edit configmap <resource-name>
        ```

=== ":no_entry: Incorrect"

    **Example 1:**

    ```yaml
    cat <<EOF | kubectl create -f -
    # code
    EOF
    ```

    **Example 2:**

    ```yaml
    kubectl apply -f - <<EOF
    # code
    EOF
    ```

## Referencing variables in code blocks

>Format variables in code blocks like so: <service-name>

> - All lower case
- Hyphens between words
- Explanation for each variable below code block
- Explanation format is “Where... `<service-name>` is…"
- If there are multiple variables, see below.

### Single variable
=== ":white_check_mark: Correct"
    ```bash
    kn create service <service-name>
    ```
    Where `<service-name>` is the name of your Knative Service.

=== ":no_entry: Incorrect"
    ```bash
    kn create service {SERVICE_NAME}
    ```
    {SERVICE_NAME} = The name of your service


### Multiple variables

=== ":white_check_mark: Correct"
    ```bash
    kn create service <service-name> --revision-name <revision-name>
    ```
    Where:

    * `<service-name>` is the name of your Knative Service.
    * `<revision-name>` is the desired name of your revision

=== ":no_entry: Incorrect"
    ```bash
    kn create service <service-name> --revision-name <revision-name>
    ```
    Where `<service-name>` is the name of your Knative Service.<br>
    Where `<revision-name>` is the desired name of your revision



## CLI output
> CLI Output should include the custom css "{ .bash .no-copy }" in place of "bash" which removes the "Copy to clipboard button" on the right side of the code block
=== ":white_check_mark: Correct"
    ```{ .bash .no-copy }
    <some-code>
    ```

=== ":no_entry: Incorrect"
    ```bash
    <some-code>
    ```

=== ":white_check_mark: Correct Formatting"
    ````
    ```{ .bash .no-copy }
    <some-code>
    ```
    ````
=== ":no_entry: Incorrect Formatting"
    ````
    ```bash
    <some-code>
    ```
    ````
