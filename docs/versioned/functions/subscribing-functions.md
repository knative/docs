---
audience: developer
components:
  - functions
function: how-to
---

# Subscribe functions to CloudEvents

### Prerequisites

- Knative Eventing installed on the cluster

### Procedure

--8<-- "proc-subscribe-function.md"

### Deployment with Triggers

When invoking `func deploy` the CLI will create Knative Triggers for the function.

=== "func"

    Deploy the function with Triggers by running the command inside the project directory:

    ```bash
    func deploy
    ```

=== "kn func"

    Deploy the function with Triggers by running the command inside the project directory:

    ```bash
    kn func deploy
    ```

!!! Success "Expected output"
    ```{ .bash .no-copy }
        🙌 Function image built: <registry>/hello:latest
        🎯 Creating Triggers on the cluster
        ✅ Function deployed in namespace "default" and exposed at URL:
        http://hello.default.127.0.0.1.sslip.io
    ```
