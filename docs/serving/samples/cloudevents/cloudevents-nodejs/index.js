/*
Copyright 2020 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

const express = require('express')
const { CloudEvent, Emitter, HTTP } = require('cloudevents')
const PORT = process.env.PORT || 8080
const target = process.env.K_SINK
const app = express()

const main = () => {
  app.listen(PORT, function () {
    console.log(`Cookie monster is hungry for some cloudevents on port ${PORT}!`)
    const modeMessage = target ? `send cloudevents to K_SINK: ${target}` : 'reply back with cloudevents'
    console.log(`Cookie monster is going to ${modeMessage}`)
  })
}

// handle shared the logic for producing the Response event from the Request.
const handle = (data) => {
  return { message: `Hello, ${data.name ? data.name : 'nameless'}` }
}

// receiveAndSend responds with ack, and send a new event forward
const receiveAndSend = (cloudEvent, res) => {
  const data = handle(cloudEvent.data)
  const newCloudEvent = new CloudEvent({
    type: 'dev.knative.docs.sample',
    source: 'https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-nodejs',
    time: new Date(),
    data
  })

  // With only an endpoint URL, this creates a v1 emitter
  const emitter = new Emitter({
    url: target
  })

  // Reply back to dispatcher/client as soon as possible
  res.status(202).end()

  // Send the new Event to the K_SINK
  emitter.send(newCloudEvent)
    .then((res) => {
      console.log(`Sent event: ${JSON.stringify(newCloudEvent, null, 2)}`)
      console.log(`K_SINK responded: ${JSON.stringify({ status: res.status, headers: res.headers, data: res.data }, null, 2)}`)
    })
    .catch(console.error)
}

// receiveAndReply responds with new event
const receiveAndReply = (cloudEvent, res) => {
  const data = handle(cloudEvent.data)
  const newCloudEvent = new CloudEvent({
    type: 'dev.knative.docs.sample',
    source: 'https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-nodejs',
    time: new Date(),
    data
  })

  console.log(`Reply event: ${JSON.stringify(newCloudEvent, null, 2)}`)
  const message = HTTP.binary(newCloudEvent);
  res.set(message.headers)
  res.status(200).send(message.body)
}

app.use((req, res, next) => {
  let data = ''
  req.setEncoding('utf8')
  req.on('data', function (chunk) {
    data += chunk
  })
  req.on('end', function () {
    req.body = data
    next()
  })
})

app.post('/', function (req, res) {
  try {
    const event = HTTP.toEvent({headers: req.headers, body: req.body})
    console.log(`Accepted event: ${JSON.stringify(event, null, 2)}`)
    target ? receiveAndSend(event, res) : receiveAndReply(event, res)
  } catch (err) {
    console.error(err)
    res.status(415)
      .header('Content-Type', 'application/json')
      .send(JSON.stringify(err))
  }
})

main()
