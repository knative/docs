# Code Block Guidance

## Words requiring code formatting
Use code formatting to indicate special purpose text. Apply code formatting to the following content:

* Text that the user enters into a field
* Filenames and path names
* Configuration file content
* Sections of code
* Programming examples
* Command line text
* Environment variable text



## Referencing Variables in Code Blocks

Format variables in code blocks like so: <service-name>

- All lower case
- Hyphens between words
- Explanation for each variable below code block
- Explanation format is “Where... `<service-name>` is…
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
> Be sure to specify the language your code is in, if relevant. In the below example, the :white_check_mark: Correct example uses "go" the :no_entry: Incorrect example uses "bash"

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
> CLI Output should include the custom css "{ .bash .no-copy }" in place of "bash" which removes the "Copy to Clipboard button"
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
