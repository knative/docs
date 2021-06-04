# Documenting Code

??? tip "Looking for a template?"
    //todo

## Documenting Commands

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
>Use **kubectl apply** for files/objects that the user creates — it works for both “create” and “update”, and the source of truth is their local files.
Use **kubectl edit** for files which are shipped as part of the Knative software, like the serving/eventing ConfigMaps.

=== ":white_check_mark: Correct"

    Creating a new file:
    ```
    kubectl apply -f - <<EOF
    # code
    EOF
    ```

    Editing a file:
    ```
    kubectl -n <namespace> edit cm <filename>
    ```

=== ":no_entry: Incorrect"
    ```
    cat <<EOF | kubectl create -f -
    # code
    EOF
    ```


## Words requiring code formatting
Use code formatting to indicate special purpose text. Apply code formatting to the following content:

* Filenames and path names
* Any text that goes into a CLI


## Referencing Variables in Code Blocks

>Format variables in code blocks like so: <service-name>

> - All lower case
- Hyphens between words
- Explanation for each variable below code block
- Explanation format is “Where... `<service-name>` is…"
- If there are multiple variables, see below.

### Single Variable
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


### Multiple Variables

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


## CLI Input and Output
### CLI Input
> Be sure to specify the language your code is in, bash for any CLI commands.

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

### CLI Output
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



//TODO CONTENT TABS (ex. kn + YAML)
