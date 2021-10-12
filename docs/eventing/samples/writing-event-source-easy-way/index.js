const { CloudEvent, HTTPEmitter } = require("cloudevents-sdk");

let sinkUrl = process.env['K_SINK'];

console.log("Sink URL is " + sinkUrl);

let emitter = new HTTPEmitter({
    url: sinkUrl
});

let eventIndex = 0;
setInterval(function () {
    console.log("Emitting event #" + ++eventIndex);

    let myevent = new CloudEvent({
        source: "urn:event:from:my-api/resource/123",
        type: "your.event.source.type",
        id: "your-event-id",
        dataContentType: "application/json",
        data: {"hello": "World " + eventIndex},
    });

    // Emit the event
    emitter.send(myevent)
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
