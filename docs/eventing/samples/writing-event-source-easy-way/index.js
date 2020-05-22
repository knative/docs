const v1 = require("cloudevents-sdk/v1");

let sinkUrl = process.env['K_SINK'];

console.log("Sink URL is " + sinkUrl);

let config = {
    method: "POST",
    url: sinkUrl
};

// The binding instance
let binding = new v1.BinaryHTTPEmitter(config);

let eventIndex = 0;
setInterval(function () {
    console.log("Emitting event #" + ++eventIndex);

    // create the event
    let myevent = v1.event()
        .id('your-event-id')
        .type("your.event.source.type")
        .source("urn:event:from:your-api/resource/123")
        .dataContentType("application/json")
        .data({"hello": "World " + eventIndex});

    // Emit the event
    binding.emit(myevent)
        .then(response => {
            // Treat the response
            console.log("Event posted successfully");
            console.log(response.data);
        })
        .catch(err => {
            // Deal with errors
            console.log("Error during event post");
            console.error(err);
        });
}, 1000);

registerGracefulExit();

function registerGracefulExit() {
    let logExit = function () {
        console.log("Exiting");
        process.exit();
    };

    // handle graceful exit
    //do something when app is closing
    process.on('exit', logExit);
    //catches ctrl+c event
    process.on('SIGINT', logExit);
    process.on('SIGTERM', logExit);
    // catches "kill pid" (for example: nodemon restart)
    process.on('SIGUSR1', logExit);
    process.on('SIGUSR2', logExit);
}
