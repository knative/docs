const { CloudEvent, Emitter, emitterFor, httpTransport } = require('cloudevents');

const K_SINK = process.env['K_SINK'];
K_SINK || logExit('Error: K_SINK Environment variable is not defined', 1);
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
const emit = emitterFor(httpTransport(K_SINK));

// Send the CloudEvent any time a Node.js 'cloudevent' event is emitted
Emitter.on('cloudevent', emit);

registerGracefulExit();

function registerGracefulExit() {
  // Catch termination signals without passing their names to logExit.
  for (const signal of ['SIGINT', 'SIGTERM', 'SIGUSR1', 'SIGUSR2']) {
    process.on(signal, () => logExit());
  }
}

function logExit(message = 'Exiting...', code = 0) {
  // Handle graceful exit
  process.stdout.write(`${message}\n`);
  process.exit(code);
}
