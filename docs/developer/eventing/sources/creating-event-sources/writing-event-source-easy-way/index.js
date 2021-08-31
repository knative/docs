const got = require('got');
const { CloudEvent, Emitter, emitterFor } = require('cloudevents');

const K_SINK = process.env['K_SINK'];
K_SINK || logExit('Error: K_SINK Environment variable is not defined');
console.log(`Sink URL is ${K_SINK}`);

const source = 'urn:event:from:heartbeat/example';
const type = 'heartbeat.example';

let eventIndex = 0;
setInterval(() => {
  console.log(`Emitting event # ${++eventIndex}`);

  // Create a new CloudEvent each second
  const event = new CloudEvent({ source, type, data: {'hello': `World # ${eventIndex}`} });

  // Emits the 'cloudevent' Node.js event application-wide
  event.emit();
}, 1000);

// Create a function that can post an event
const emit = emitterFor(event => {
  got.post(K_SINK, event)
    .then(response => {
      console.log('Event posted successfully');
      console.log(response.data);
    })
    .catch(err => {
      console.log('Error during event post');
      console.error(err);
    });
  });

// Send the CloudEvent any time a Node.js 'cloudevent' event is emitted
Emitter.on('cloudevent', emit);

registerGracefulExit();

function registerGracefulExit() {
  process.on('exit', logExit);
  //catches ctrl+c event
  process.on('SIGINT', logExit);
  process.on('SIGTERM', logExit);
  // catches 'kill pid' (for example: nodemon restart)
  process.on('SIGUSR1', logExit);
  process.on('SIGUSR2', logExit);
}

function logExit(message = 'Exiting...') {
  // Handle graceful exit
  console.log(message);
  process.exit();
}
