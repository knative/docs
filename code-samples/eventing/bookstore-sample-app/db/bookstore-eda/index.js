const express = require('express');
const { HTTP, CloudEvent } = require('cloudevents');

const app = express();
const port = 8000;


// Middleware to parse JSON bodies
app.use(express.json()); // This line is crucial


app.post('/add', async (req, res) => {
    try {
        // Use the HTTP utility to convert the incoming HTTP request to a CloudEvent
        const receivedEvent = HTTP.toEvent({ headers: req.headers, body: req.body });
        const brokerURI = process.env.K_SINK;

        // Ensure the event is of the type you expect
        if (receivedEvent.type === 'new-comment') {
            const comment = receivedEvent.data; // Assuming the data contains the comment directly

            // Forward the event to the broker by sending the post request to the broker
            const response = await fetch(brokerURI, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'ce-specversion': '1.0',
                    'ce-type': 'sentiment-analysis-request',
                    'ce-source': 'bookstore-eda',
                    'ce-id': '1234',
                },
                body: JSON.stringify(comment),
            });

            console.log('Received event:', receivedEvent);

            console.log('Forwarded event:', response);


            // Return the received cloudevent as a response
            res.status(200).json(response.text());


        } else {
            // If the event type is not what you expect, respond accordingly
            res.status(400).json({ error: 'Unexpected event type' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
