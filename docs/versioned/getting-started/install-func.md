---
audience: developer
components:
  - functions
function: tutorial
---

<span id="installing-knative-functions"></span><span id="installing-the-func-cli"></span>

# Install func

Install the standalone Functions CLI on your machine. This track uses `func`
throughout; you do not need to install `kn` or configure a plugin.

=== "Homebrew"

    If you use [Homebrew](https://brew.sh/), run:

    ```bash
    brew install knative-extensions/kn-plugins/func
    ```

=== "Release binary"

    Download the binary for your operating system and CPU architecture from the
    [Functions release page](https://github.com/knative/func/releases).

    Rename it to `func` (`func.exe` on Windows), and put it in a directory on your
    `PATH`. On Linux and macOS, make the downloaded file executable with
    `chmod +x func` before moving it.

Verify the installation:

```bash
func version
```

You should see a version number. If the command is not found, check that the
binary is on your `PATH` before continuing.

Next, [create and change a function](create-a-function.md).

<span id="installing-the-kn-func-cli-plugin"></span>

For plugin installation and other options, see the
[Functions CLI installation guide](../functions/install-func.md).
