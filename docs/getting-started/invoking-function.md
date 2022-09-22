# Invoking a Knative Function

You can use the `func invoke` CLI command to send a test request to invoke a
function either locally or on your Knative cluster. This command can be used
to test that a function is working and able to receive events correctly. By
default, function templates echo the CloudEvent data received.

=== "func"

    Invoke the function by running the command from within the function project directory:

    ```bash
    func invoke
    ```

    !!! Success "Expected output"
        ```{ .console .no-copy }
          Received response
          Context Attributes,
            specversion: 1.0
            type: echo
            source: event.handler
            id: 3ac510fc-95f8-4958-a18e-3ffbff22c842
            time: 2022-09-23T12:45:23.981Z
            datacontenttype: application/json; charset=utf-8
          Data,
            {
              "id": "89f49b4c-c8c4-46d2-a99e-eeca44fa894b",
              "time": "2022-09-23T12:45:18.852Z",
              "type": "boson.fn",
              "source": "/boson/fn",
              "specversion": "1.0",
              "datacontenttype": "application/json",
              "data": {
                "message": "Hello World"
              }
            }
        ```
